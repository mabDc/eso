package com.mr.flutter.plugin.filepicker;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.storage.StorageManager;
import android.provider.DocumentsContract;
import android.provider.OpenableColumns;
import android.util.Log;
import android.webkit.MimeTypeMap;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Array;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Random;

public class FileUtils {

    private static final String TAG = "FilePickerUtils";
    private static final String PRIMARY_VOLUME_NAME = "primary";

    public static String[] getMimeTypes(final ArrayList<String> allowedExtensions) {

        if (allowedExtensions == null || allowedExtensions.isEmpty()) {
            return null;
        }

        final ArrayList<String> mimes = new ArrayList<>();

        // Log.d(TAG, "allowedExtensions:" + allowedExtensions);
        // Log.d(TAG, "allowedExtensions.size:" + allowedExtensions.size());


        for (int i = 0; i < allowedExtensions.size(); i++) {
            final String mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(allowedExtensions.get(i));
            if (mime == null) {
                Log.w(TAG, "Custom file type " + allowedExtensions.get(i) + " is unsupported and will be ignored.");
                continue;
            }

            mimes.add(mime);
        }
        Log.d(TAG, "Allowed file extensions mimes: " + mimes);
        return mimes.toArray(new String[0]);
    }

    public static String getFileName(Uri uri, final Context context) {
        String result = null;

        try {

            if (uri.getScheme().equals("content")) {
                Cursor cursor = context.getContentResolver().query(uri, new String[]{OpenableColumns.DISPLAY_NAME}, null, null, null);
                try {
                    if (cursor != null && cursor.moveToFirst()) {
                        result = cursor.getString(cursor.getColumnIndexOrThrow(OpenableColumns.DISPLAY_NAME));
                    }
                } finally {
                    cursor.close();
                }
            }
            if (result == null) {
                result = uri.getPath();
                int cut = result.lastIndexOf('/');
                if (cut != -1) {
                    result = result.substring(cut + 1);
                }
            }
        } catch (Exception ex){
            Log.e(TAG, "Failed to handle file name: " + ex.toString());
        }

        return result;
    }

    public static boolean clearCache(final Context context) {
        try {
            final File cacheDir = new File(context.getCacheDir() + "/file_picker/");
            final File[] files = cacheDir.listFiles();

            if (files != null) {
                for (final File file : files) {
                    file.delete();
                }
            }
        } catch (final Exception ex) {
            Log.e(TAG, "There was an error while clearing cached files: " + ex.toString());
            return false;
        }
        return true;
    }

    public static void loadData(final File file, FileInfo.Builder fileInfo) {
        try {
            int size = (int) file.length();
            byte[] bytes = new byte[size];

            try {
                BufferedInputStream buf = new BufferedInputStream(new FileInputStream(file));
                buf.read(bytes, 0, bytes.length);
                buf.close();
            } catch (FileNotFoundException e) {
                Log.e(TAG, "File not found: " + e.getMessage(), null);
            } catch (IOException e) {
                Log.e(TAG, "Failed to close file streams: " + e.getMessage(), null);
            }
            fileInfo.withData(bytes);

        }  catch (Exception e) {
            Log.e(TAG, "Failed to load bytes into memory with error " + e.toString() + ". Probably the file is too big to fit device memory. Bytes won't be added to the file this time.");
        }
    }

    public static FileInfo openFileStream(final Context context, final Uri uri, boolean withData) {

        Log.i(TAG, "Caching from URI: " + uri.toString());
        FileOutputStream fos = null;
        final FileInfo.Builder fileInfo = new FileInfo.Builder();
        final String fileName = FileUtils.getFileName(uri, context);
        final String path = context.getCacheDir().getAbsolutePath() + "/file_picker/" + (fileName != null ? fileName : new Random().nextInt(100000));

        final File file = new File(path);

        if(!file.exists()) {
            file.getParentFile().mkdirs();
            try {
                fos = new FileOutputStream(path);
                try {
                    final BufferedOutputStream out = new BufferedOutputStream(fos);
                    final InputStream in = context.getContentResolver().openInputStream(uri);

                    final byte[] buffer = new byte[8192];
                    int len = 0;

                    while ((len = in.read(buffer)) >= 0) {
                        out.write(buffer, 0, len);
                    }

                    out.flush();
                } finally {
                    fos.getFD().sync();
                }
            } catch (final Exception e) {
                try {
                    fos.close();
                } catch (final IOException | NullPointerException ex) {
                    Log.e(TAG, "Failed to close file streams: " + e.getMessage(), null);
                    return null;
                }
                Log.e(TAG, "Failed to retrieve path: " + e.getMessage(), null);
                return null;
            }
        }

        Log.d(TAG, "File loaded and cached at:" + path);

        if(withData) {
            loadData(file, fileInfo);
        }

        fileInfo
                .withPath(path)
                .withName(fileName)
                .withUri(uri)
                .withSize(Long.parseLong(String.valueOf(file.length())));

        return fileInfo.build();
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    @Nullable
    @SuppressWarnings("deprecation")
    public static String getFullPathFromTreeUri(@Nullable final Uri treeUri, Context con) {
        if (treeUri == null) {
            return null;
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            if (isDownloadsDocument(treeUri)) {
                String docId = DocumentsContract.getDocumentId(treeUri);
                String extPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getPath();
                if (docId.equals("downloads")) {
                    return extPath;
                } else if (docId.matches("^ms[df]\\:.*")) {
                    String fileName = getFileName(treeUri, con);
                    return extPath + "/" + fileName;
                } else if (docId.startsWith("raw:")) {
                    String rawPath = docId.split(":")[1];
                    return rawPath;
                }
                return null;
            }
        }

        String volumePath = getVolumePath(getVolumeIdFromTreeUri(treeUri), con);
        FileInfo.Builder fileInfo = new FileInfo.Builder();

        if (volumePath == null) {
            return File.separator;
        }

        if (volumePath.endsWith(File.separator))
            volumePath = volumePath.substring(0, volumePath.length() - 1);

        String documentPath = getDocumentPathFromTreeUri(treeUri);

        if (documentPath.endsWith(File.separator))
            documentPath = documentPath.substring(0, documentPath.length() - 1);

        if (documentPath.length() > 0) {
            if (documentPath.startsWith(File.separator)) {
                return volumePath + documentPath;
            }
            else {
                return volumePath + File.separator + documentPath;
            }
        } else {
            return volumePath;
        }
    }

    @Nullable
    private static String getDirectoryPath(Class<?> storageVolumeClazz, Object storageVolumeElement) {
        try {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                Method getPath = storageVolumeClazz.getMethod("getPath");
                return (String) getPath.invoke(storageVolumeElement);
            }

            Method getDirectory = storageVolumeClazz.getMethod("getDirectory");
            File f = (File) getDirectory.invoke(storageVolumeElement);
            if (f != null)
                return f.getPath();

        } catch (Exception ex) {
            return null;
        }
        return null;
    }

    @SuppressLint("ObsoleteSdkInt")
    private static String getVolumePath(final String volumeId, Context context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) return null;
        try {
            StorageManager mStorageManager =
                    (StorageManager) context.getSystemService(Context.STORAGE_SERVICE);
            Class<?> storageVolumeClazz = Class.forName("android.os.storage.StorageVolume");
            Method getVolumeList = mStorageManager.getClass().getMethod("getVolumeList");
            Method getUuid = storageVolumeClazz.getMethod("getUuid");
            Method isPrimary = storageVolumeClazz.getMethod("isPrimary");
            Object result = getVolumeList.invoke(mStorageManager);
            if (result == null)
                return null;

            final int length = Array.getLength(result);
            for (int i = 0; i < length; i++) {
                Object storageVolumeElement = Array.get(result, i);
                String uuid = (String) getUuid.invoke(storageVolumeElement);
                Boolean primary = (Boolean) isPrimary.invoke(storageVolumeElement);

                // primary volume?
                if (primary != null && PRIMARY_VOLUME_NAME.equals(volumeId)) {
                    return getDirectoryPath(storageVolumeClazz, storageVolumeElement);
                }

                // other volumes?
                if (uuid != null && uuid.equals(volumeId)) {
                    return getDirectoryPath(storageVolumeClazz, storageVolumeElement);
                }
            }
            // not found.
            return null;
        } catch (Exception ex) {
            return null;
        }
    }

    private static boolean isDownloadsDocument(Uri uri) {
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private static String getVolumeIdFromTreeUri(final Uri treeUri) {
        final String docId = DocumentsContract.getTreeDocumentId(treeUri);
        final String[] split = docId.split(":");
        if (split.length > 0) return split[0];
        else return null;
    }


    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private static String getDocumentPathFromTreeUri(final Uri treeUri) {
        final String docId = DocumentsContract.getTreeDocumentId(treeUri);
        final String[] split = docId.split(":");
        if ((split.length >= 2) && (split[1] != null)) return split[1];
        else return File.separator;
    }

}