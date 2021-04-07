function JsDecoder() {
    this.s = '';
    this.len = 0;

    this.i = 0;
    this.lvl = 0; /* indent level */
    this.code = [''];
    this.row = 0;
    this.switches = [];

    this.lastWord = '';
    this.nextChar = '';
    this.prevChar = '';
    this.isAssign = false;

    this.decode = function () {
        this.s = this.s.replace(/[\r\n\f]+/g, "\n");
        this.len = this.s.length;
        while (this.i < this.len) {
            var c = this.s.charAt(this.i);
            this.charInit();
            this.switch_c(c);
            this.i++;
        }
        return this.code.join("\n");
    };
    this.switch_c = function (c) {
        switch (c) {
            case "\n":
                this.linefeed();
                break;

            case ' ':
            case "\t":
                this.space();
                break;

            case '{': this.blockBracketOn(); break;
            case '}': this.blockBracketOff(); break;

            case ':': this.colon(); break;
            case ';': this.semicolon(); break;

            case '(': this.bracketOn(); break;
            case ')': this.bracketOff(); break;
            case '[': this.squareBracketOn(); break;
            case ']': this.squareBracketOff(); break;

            case '"':
            case '`':
            case "'":
                this.quotation(c);
                break;

            case '/':
                if ('/' == this.nextChar) {
                    this.lineComment();
                } else if ('*' == this.nextChar) {
                    this.comment();
                } else {
                    this.slash();
                }
                break;

            case ',': this.comma(); break;
            case '.': this.dot(); break;

            case '~':
            case '^':
                this.symbol1(c);
                break;

            case '-': case '+': case '*': case '%':
            case '<': case '=': case '>': case '?':
            case ':': case '&': case '|': case '/':
                this.symbol2(c);
                break;

            case '!':
                if ('=' == this.nextChar) {
                    this.symbol2(c);
                } else {
                    this.symbol1(c);
                }
                break;

            default:
                if (/\w/.test(c)) { this.alphanumeric(c); }
                else { this.unknown(c); }
                break;
        }
        c = this.s.charAt(this.i);
        if (!/\w/.test(c)) {
            this.lastWord = '';
        }
    };
    this.blockBracketOn = function () {
        this.isAssign = false;
        var nextNW = this.nextNonWhite(this.i);
        if ('}' == nextNW) {
            var ss = (this.prevChar == ')' ? ' ' : '');
            this.write(ss + '{');
            this.lvl++;
            return;

        }
        if (/^\s*switch\s/.test(this.getCurrentLine())) {
            this.switches.push(this.lvl);
        }
        var line = this.getCurrentLine();
        var line_row = this.row;
        var re = /(,)\s*(\w+\s*:\s*function\s*\([^\)]*\)\s*)$/;
        if (re.test(line)) {
            this.replaceLine(this.code[line_row].replace(re, '$1'));
            this.writeLine();
            var match = re.exec(line);
            this.write(match[2]);
        }

        /* example: return {
            title: 'Jack Slocum',
            iconCls: 'user'}
            After return bracket cannot be on another line
        */
        if (/^\s*return\s*/.test(this.code[this.row])) {
            if (/^\s*return\s+\w+/.test(this.code[this.row])) {
                this.writeLine();
            } else if (this.prevChar != ' ') {
                this.write(' ');
            }
            this.write('{');
            this.writeLine();
            this.lvl++;
            return;
        }

        if (/function\s*/.test(this.code[this.row]) || this.isBlockBig()) {
            this.writeLine();
        } else {
            if (this.prevChar != ' ' && this.prevChar != "\n" && this.prevChar != '(') {
                /*  && this.prevChar != '(' && this.prevChar != '[' */
                this.write(' ');
            }
        }
        this.write('{');
        this.lvl++;
        if ('{' != nextNW) {
            this.writeLine();
        }
    };
    this.isBlockBig = function () {
        var i = this.i + 1;
        var count = 0;
        var opened = 0;
        var closed = 0;
        while (i < this.len - 1) {
            i++;
            var c = this.s.charAt(i);
            if (/\s/.test(c)) {
                continue;
            }
            if ('}' == c && opened == closed) {
                break;
            }
            if ('{' == c) { opened++; }
            if ('}' == c) { closed++; }
            count++;
            if (count > 80) {
                return true;
            }
        }
        return (count > 80);
    };
    this.blockBracketOff = function () {
        var nextNW = this.nextNonWhite(this.i);
        var prevNW = this.prevNonWhite(this.i);
        var line = this.getCurrentLine();

        if (prevNW != '{') {
            if (line.length && nextNW != ';' && nextNW != '}' && nextNW != ')' && nextNW != ',') {
                //this.semicolon();
                this.writeLine();
            } else if (line.length && prevNW != ';' && nextNW == '}' && this.isAssign) {
                this.semicolon();
            } else if (line.length && this.isAssign && prevNW != ';') {
                this.semicolon();
            } else if (line.length && prevNW != ';') {
                if (/^\s*(else)?\s*return[\s(]+/i.test(line)) {
                    this.semicolon();
                } else {
                    this.writeLine();
                }
            }
        }
        this.write('}');

        if (',' == nextNW) {
            this.write(',');
            this.goNextNonWhite();
        }
        var next3 = this.nextManyNW(3);
        if (next3 == '(),') {
            this.write('(),');
            this.goNextManyNW('(),');
            this.writeLine();
        }
        else if (next3 == '();') {
            this.write('();');
            this.goNextManyNW('();');
            this.writeLine();
        }
        else if (next3 == '():') {
            this.write('()');
            this.goNextManyNW('()');
            this.write(' : ');
            this.goNextNonWhite();
        }
        else {
            if ('{' == prevNW) {
                if (',' == nextNW && this.getCurrentLine().length < 80) {
                    this.write(' ');
                } else {
                    if (this.nextWord() || '}' == nextNW) {
                        this.writeLine();
                    }
                }
            } else {
                if (')' != nextNW && ']' != nextNW) {
                    if (',' == nextNW && /^[\s\w,]+\)/.test(this.s.substr(this.i, 20))) {
                        this.write(' ');
                    } else {
                        this.writeLine();
                    }
                }
            }
        }
        this.lvl--;

        if (this.switches.length && this.switches[this.switches.length - 1] == this.lvl) {
            var row = this.row - 1;
            var spaces1 = str_repeat(' ', this.lvl * 4);
            var spaces2 = str_repeat(' ', (this.lvl + 1) * 4);
            var sw1 = new RegExp('^' + spaces1 + '(switch\\s|{)');
            var sw2 = new RegExp('^' + spaces2 + '(case|default)[\\s:]');
            var sw3 = new RegExp('^' + spaces2 + '[^\\s]');
            while (row > 0) {
                row--;
                if (sw1.test(this.code[row])) {
                    break;
                }
                if (sw2.test(this.code[row])) {
                    continue;
                }
                this.replaceLine('    ' + this.code[row], row);
                /*
                if (sw3.test(this.code[row])) {
                    this.replaceLine('    ' + this.code[row], row);
                }
                */
            }
            this.switches.pop();
        }

        // fix missing brackets for sub blocks

        if (this.sub) {
            return;
        }

        var re1 = /^(\s*else\s*if)\s*\(/;
        var re2 = /^(\s*else)\s+[^{]+/;

        var part = this.s.substr(this.i + 1, 100);

        if (re1.test(part)) {
            this.i += re1.exec(part)[1].length;
            this.write('else if');
            this.lastWord = 'if';
            //debug(this.getCurrentLine(), 're1');
            this.fixSub('else if');
            //debug(this.getCurrentLine(), 're1 after');
        } else if (re2.test(part)) {
            this.i += re2.exec(part)[1].length;
            this.write('else');
            this.lastWord = 'else';
            //debug(this.getCurrentLine(), 're2');
            this.fixSub('else');
            //debug(this.getCurrentLine(), 're2 after');
        }
    };
    this.bracketOn = function () {
        if (this.isKeyword() && this.prevChar != ' ' && this.prevChar != "\n") {
            this.write(' (');
        } else {
            this.write('(');
        }
    };
    this.bracketOff = function () {
        this.write(')');
        /*
        if (/\w/.test(this.nextNonWhite(this.i))) {
            this.semicolon();
        }
        */
        if (this.sub) {
            return;
        }
        var re = new RegExp('^\\s*(if|for|while|do)\\s*\\([^{}]+\\)$', 'i');
        var line = this.getCurrentLine();
        if (re.test(line)) {
            var c = this.nextNonWhite(this.i);
            if ('{' != c && ';' != c && ')' != c) {
                var opened = 0;
                var closed = 0;
                var foundFirst = false;
                var semicolon = false;
                var fix = false;
                for (var k = 0; k < line.length; k++) {
                    if (line.charAt(k) == '(') {
                        foundFirst = true;
                        opened++;
                    }
                    if (line.charAt(k) == ')') {
                        closed++;
                        if (foundFirst && opened == closed) {
                            if (k == line.length - 1) {
                                fix = true;
                            } else {
                                break;
                            }
                        }
                    }
                }
                if (fix) {
                    //alert(this.s.substr(this.i));
                    //throw 'asdas';
                    //alert(line);
                    this.fixSub(re.exec(line)[1]);
                    /*
                    this.writeLine();
                    this.lvl2++;
                    var indent = '';
                    for (var j = 0; j < this.lvl2; j++) {
                        indent += '    ';
                    }
                    this.write(indent);
                    */
                }
            }
        }
    };
    this.sub = false;

    this.orig_i = null;
    this.orig_lvl = null;
    this.orig_code = null;
    this.orig_row = null;
    this.orig_switches = null;

    this.restoreOrig = function (omit_i) {
        this.sub = false;

        if (!omit_i) { this.i = this.orig_i; }
        this.lvl = this.orig_lvl;
        this.code = this.orig_code;
        this.row = this.orig_row;
        this.switches = this.orig_switches;

        this.prevCharInit();

        this.lastWord = '';
        this.charInit();
        this.isAssign = false;
    };
    this.combineSub = function () {
        //debug(this.orig_code, 'orig_code');
        for (i = 0; i < this.code.length; i++) {
            var line = this.orig_code[this.orig_row];
            if (0 == i && line.length) {
                if (line.substr(line.length - 1, 1) != ' ') {
                    this.orig_code[this.orig_row] += ' ';
                }
                this.orig_code[this.orig_row] += this.code[i].trim();
            } else {
                this.orig_code[this.orig_row + i] = this.code[i];
            }
        }
        //debug(this.code, 'sub_code');
        //debug(this.orig_code, 'code');
    };
    this.fixSub = function (keyword) {
        // repair missing {}: for, if, while, do, else, else if

        if (this.sub) {
            return;
        }

        if ('{' == this.nextNonWhite(this.i)) {
            return;
        }

        var firstWord = this.nextWord();

        //debug(this.code, 'fixSub('+keyword+') start');

        this.orig_i = this.i;
        this.orig_lvl = this.lvl;
        this.orig_code = this.code;
        this.orig_row = this.row;
        this.orig_switches = this.switches;

        this.sub = true;
        this.code = [''];
        this.prevChar = '';
        this.row = 0;
        this.switches = [];
        this.isAssign = false;

        this.i++;

        var b1 = 0;
        var b2 = 0;
        var b3 = 0;

        if ('else if' == keyword) {
            var first_b2_closed = false;
        }

        var found = false;

        /*
            try catch
            switch
            while do
            if else else else...

            todo: nestings
            if ()
                if () 
                    if ()
                        for ()
                            if () asd();
                    else
                        asd();
                else
                    if ()
                        try {
                        } catch {}
            else
            if ()
        */
        var b1_lastWord = false;
        var b2_lastWord = false;

        while (!found && this.i < this.len) {
            var c = this.s.charAt(this.i);
            this.charInit();
            switch (c) {
                case '{': b1++; break;
                case '}':
                    b1--;
                    // case: for(){if (!c.m(g))c.g(f, n[t] + g + ';')}
                    if (0 == b1 && 0 == b2 && 0 == b3 && this.lvl - 1 == this.orig_lvl) {
                        var nextWord = this.nextWord();
                        if ('switch' == firstWord) {
                            found = true;
                            break;
                        }
                        if ('try' == firstWord && 'catch' == b1_lastWord) {
                            found = true;
                            break;
                        }
                        if ('while' == firstWord && 'do' == b1_lastWord) {
                            found = true;
                            break;
                        }
                        if ('if' == firstWord) {
                            // todo
                        }
                        if ('if' == keyword && 'else' == nextWord && 'if' != firstWord) {
                            found = true;
                            break;
                        }
                        b1_lastWord = nextWord;
                    }
                    break;
                case '(': b2++; break;
                case ')':
                    b2--;
                    if ('else if' == keyword && 0 == b2 && !first_b2_closed) {
                        if (this.nextNonWhite(this.i) == '{') {
                            this.write(c);
                            this.combineSub();
                            this.restoreOrig(true);
                            //debug(this.code, 'fixSub('+keyword+') b2 return');
                            //debug(this.s.charAt(this.i), ' b2 current char');
                            return;
                        }
                        // do not restore orig i
                        this.write(c);
                        this.combineSub();
                        this.restoreOrig(true);
                        this.fixSub('if');
                        //debug(this.code, 'fixSub('+keyword+') b2 return');
                        return;
                    }
                    break;
                case '[': b3++; break;
                case ']': b3--; break;
                case ';':
                    //debug(this.getCurrentLine(), 'semicolon');
                    //debug([b1, b2, b3]);
                    if (0 == b1 && 0 == b2 && 0 == b3 && this.lvl == this.orig_lvl && 'if' != firstWord) {
                        found = true;
                    }
                    break;
            }
            if (-1 == b1 && b2 == 0 && b3 == 0 && this.prevNonWhite(this.i) != '}') {
                this.write(';');
                this.i--;
                found = true;
            } else if (b1 < 0 || b2 < 0 || b3 < 0) {
                found = false;
                break;
            } else {
                this.switch_c(c);
            }
            this.i++;
        }
        this.i--;

        if (found) {
            /*
            var re = /^\s*(else\s+[\s\S]*)$/;
            if ('if' == keyword && re.test(this.getCurrentLine())) {
                this.i = this.i - re.exec(this.getCurrentLine())[1].length;
                this.code[this.row] = '';
            }
            */
            this.s = this.s.substr(0, this.orig_i + 1) + '{' + this.code.join("\n") + '}' + this.s.substr(this.i + 1);
            this.len = this.s.length;
        }

        //debug("{\n" + this.code.join("\n") + '}', 'fixSub('+keyword+') result');
        //debug(found, 'found');

        this.restoreOrig(false);
    };
    this.squareBracketOn = function () {
        this.checkKeyword();
        this.write('[');
    };
    this.squareBracketOff = function () {
        this.write(']');
    };
    this.isKeyword = function () {
        // Check if this.lastWord is a keyword
        return this.lastWord.length && this.keywords.indexOf(this.lastWord) != -1;
    };
    this.linefeed = function () { };
    this.space = function () {
        if (!this.prevChar.length) {
            return;
        }
        if (' ' == this.prevChar || "\n" == this.prevChar) {
            return;
        }
        if ('}' == this.prevChar && ']' == this.nextChar) {
            //return;
        }
        this.write(' ');
        return;

        /*
        if (this.isKeyword()) {
            this.write(' ');
            this.lastWord = '';
        } else {
            var multi = ['in', 'new'];
            for (var i = 0; i < multi.length; i++) {
                var isKeywordNext = true;
                for (var j = 0; j < multi[i].length; j++) {
                    if (multi[i][j] != this.s.charAt(this.i + 1 + j)) {
                        isKeywordNext = false;
                        break;
                    }
                }
                if (isKeywordNext) {
                    this.write(' ');
                    this.lastWord = '';
                    break;
                }
            }
        }
        */
    };
    this.checkKeyword = function () {
        if (this.isKeyword() && this.prevChar != ' ' && this.prevChar != "\n") {
            this.write(' ');
        }
    };
    this.nextWord = function () {
        var i = this.i;
        var word = '';
        while (i < this.len - 1) {
            i++;
            var c = this.s.charAt(i);
            if (word.length) {
                if (/\s/.test(c)) {
                    break;
                } else if (/\w/.test(c)) {
                    word += c;
                } else {
                    break;
                }
            } else {
                if (/\s/.test(c)) {
                    continue;
                } else if (/\w/.test(c)) {
                    word += c;
                } else {
                    break;
                }
            }
        }
        if (word.length) {
            return word;
        }
        return false;
    };
    this.nextManyNW = function (many) {
        var ret = '';
        var i = this.i;
        while (i < this.len - 1) {
            i++;
            var c = this.s.charAt(i);
            if (!/^\s+$/.test(c)) {
                ret += c;
                if (ret.length == many) {
                    return ret;
                }
            }
        }
        return false;
    }
    this.goNextManyNW = function (cc) {
        var ret = '';
        var i = this.i;
        while (i < this.len - 1) {
            i++;
            var c = this.s.charAt(i);
            if (!/^\s+$/.test(c)) {
                ret += c;
                if (ret == cc) {
                    this.i = i;
                    this.charInit();
                    return true;
                }
                if (ret.length >= cc.length) {
                    return false;
                }
            }
        }
        return false;
    };
    this.nextNonWhite = function (i) {
        while (i < this.len - 1) {
            i++;
            var c = this.s.charAt(i);
            if (!/^\s+$/.test(c)) {
                return c;
            }
        }
        return false;
    };
    this.prevNonWhite = function (i) {
        while (i > 0) {
            i--;
            var c = this.s.charAt(i);
            if (!/^\s+$/.test(c)) {
                return c;
            }
        }
        return false;
    };
    this.goNextNonWhite = function () {
        // you need to write() this nonWhite char when calling this func
        var i = this.i;
        while (i < this.len - 1) {
            i++;
            var c = this.s.charAt(i);
            if (!/^\s+$/.test(c)) {
                this.i = i;
                this.charInit();
                return true;
            }
        }
        return false;
    };
    this.colon = function () {
        //alert(this.getCurrentLine());
        /* case 6: expr ? stat : stat */
        var line = this.getCurrentLine();
        if (/^\s*case\s/.test(line) || /^\s*default$/.test(line)) {
            this.write(':');
            this.writeLine();
        } else {
            this.symbol2(':');
        }
    };
    this.isStart = function () {
        return this.getCurrentLine().length === 0;
    };
    this.backLine = function () {
        if (!this.isStart) {
            throw 'backLine() may be called only at the start of the line';
        }
        this.code.length = this.code.length - 1;
        this.row--;
    };
    this.semicolon = function () {
        /* for statement: for (i = 1; i < len; i++) */
        this.isAssign = false;
        if (this.isStart()) {
            this.backLine();
        }
        this.write(';');
        if (/^\s*for\s/.test(this.getCurrentLine())) {
            this.write(' ');
        } else {
            this.writeLine();
        }
    };
    this.quotation = function (quotation) {
        this.checkKeyword();
        var escaped = false;
        this.write(quotation);
        while (this.i < this.len - 1) {
            this.i++;
            var c = this.s.charAt(this.i);
            if ('\\' == c) {
                escaped = (escaped ? false : true);
            }
            this.write(c);
            if (c == quotation) {
                if (!escaped) {
                    break;
                }
            }
            if ('\\' != c) {
                escaped = false;
            }
        }
        //debug(this.getCurrentLine(), 'quotation');
        //debug(this.s.charAt(this.i), 'char');
    };
    this.lineComment = function () {
        this.write('//');
        this.i++;
        while (this.i < this.len - 1) {
            this.i++;
            var c = this.s.charAt(this.i);
            if ("\n" == c) {
                this.writeLine();
                break;
            }
            this.write(c);
        }
    };
    this.comment = function () {
        this.write('/*');
        this.i++;
        var c = '';
        var prevC = '';
        while (this.i < this.len - 1) {
            this.i++;
            prevC = c;
            c = this.s.charAt(this.i);
            if (' ' == c || "\t" == c || "\n" == c) {
                if (' ' == c) {
                    if (this.getCurrentLine().length > 100) {
                        this.writeLine();
                    } else {
                        this.write(' ', true);
                    }
                } else if ("\t" == c) {
                    this.write('    ', true);
                } else if ("\n" == c) {
                    this.writeLine();
                }
            } else {
                this.write(c, true);
            }
            if ('/' == c && '*' == prevC) {
                break;
            }
        }
        this.writeLine();
    };
    this.slash = function () {
        /*
        divisor /= or *\/ (4/5 , a/5)
        regexp /\w/ (//.test() , var asd = /some/;)
        asd /= 5;
        bbb = * / (4/5)
        asd =( a/5);
        regexp = /\w/;
        /a/.test();
        var asd = /some/;
        obj = { sasd : /pattern/ig }
        */
        var a_i = this.i - 1;
        var a_c = this.s.charAt(a_i);
        for (a_i = this.i - 1; a_i >= 0; a_i--) {
            var c2 = this.s.charAt(a_i);
            if (' ' == c2 || '\t' == c2) {
                continue;
            }
            a_c = this.s.charAt(a_i);
            break;
        }
        var a = /^\w+$/.test(a_c) || ']' == a_c || ')' == a_c;
        var b = ('*' == this.prevChar);
        if (a || b) {
            if (a) {
                if ('=' == this.nextChar) {
                    var ss = this.prevChar == ' ' ? '' : ' ';
                    this.write(ss + '/');
                } else {
                    this.write(' / ');
                }
            } else if (b) {
                this.write('/ ');
            }
        } else if (')' == this.prevChar) {
            this.write(' / ');
        } else {
            var ret = '';
            if ('=' == this.prevChar || ':' == this.prevChar) {
                ret += ' /';
            } else {
                ret += '/';
            }
            var escaped = false;
            while (this.i < this.len - 1) {
                this.i++;
                var c = this.s.charAt(this.i);
                if ('\\' == c) {
                    escaped = (escaped ? false : true);
                }
                ret += c;
                if ('/' == c) {
                    if (!escaped) {
                        break;
                    }
                }
                if ('\\' != c) {
                    escaped = false;
                }
            }
            this.write(ret);
        }
    };
    this.comma = function () {
        /*
         * function arguments seperator
         * array values seperator
         * object values seperator
         */
        this.write(', ');
        var line = this.getCurrentLine();
        if (line.replace(' ', '').length > 100) {
            this.writeLine();
        }
    };
    this.dot = function () {
        this.write('.');
    };
    this.symbol1 = function (c) {
        if ('=' == this.prevChar && '!' == c) {
            this.write(' ' + c);
        } else {
            this.write(c);
        }
    };
    this.symbol2 = function (c) {
        // && !p
        // ===
        if ('+' == c || '-' == c) {
            if (c == this.nextChar || c == this.prevChar) {
                this.write(c);
                return;
            }
        }
        var ss = (this.prevChar == ' ' ? '' : ' ');
        var ss2 = ' ';
        if ('(' == this.prevChar) {
            ss = '';
            ss2 = '';
        }
        if ('-' == c && ('>' == this.prevChar || '>' == this.prevChar)) {
            this.write(' ' + c);
            return;
        }
        if (this.symbols2.indexOf(this.prevChar) != -1) {
            if (this.symbols2.indexOf(this.nextChar) != -1) {
                this.write(c + (this.nextChar == '!' ? ' ' : ''));
            } else {
                this.write(c + ss2);
            }
        } else {
            if (this.symbols2.indexOf(this.nextChar) != -1) {
                this.write(ss + c);
            } else {
                this.write(ss + c + ss2);
            }
        }
        if ('=' == c && /^[\w\]]$/.test(this.prevNonWhite(this.i)) && /^[\w\'\"\[]$/.test(this.nextNonWhite(this.i))) {
            this.isAssign = true;
        }
    };
    this.alphanumeric = function (c) {
        /* /[a-zA-Z0-9_]/ == /\w/ */
        if (this.lastWord) {
            this.lastWord += c;
        } else {
            this.lastWord = c;
        }
        if (')' == this.prevChar) {
            c = ' ' + c;
        }
        this.write(c);
    };
    this.unknown = function (c) {
        //throw 'Unknown char: "'+c+'" , this.i = ' + this.i;
        this.write(c);
    };

    this.charInit = function () {
        /*
        if (this.i > 0) {
            //this.prevChar = this.s.charAt(this.i - 1);
            var line = this.code[this.row];
            if (line.length) {
                this.prevChar = line.substr(line.length-1, 1);
            } else {
                this.prevChar = '';
            }
        } else {
            this.prevChar = '';
        }
        */
        if (this.len - 1 === this.i) {
            this.nextChar = '';
        } else {
            this.nextChar = this.s.charAt(this.i + 1);
        }
    };
    this.write = function (s, isComment) {
        if (isComment) {
            if (!/\s/.test(s)) {
                if (this.code[this.row].length < this.lvl * 4) {
                    this.code[this.row] += str_repeat(' ', this.lvl * 4 - this.code[this.row].length);
                }
            }
            this.code[this.row] += s;
        } else {
            if (0 === this.code[this.row].length) {
                var lvl = ('}' == s ? this.lvl - 1 : this.lvl);
                for (var i = 0; i < lvl; i++) {
                    this.code[this.row] += '    ';
                }
                this.code[this.row] += s;
            } else {
                this.code[this.row] += s;
            }
        }
        this.prevCharInit();
    };
    this.writeLine = function () {
        this.code.push('');
        this.row++;
        this.prevChar = "\n";
    };
    this.replaceLine = function (line, row) {
        if ('undefined' == typeof row) {
            row = false;
        }
        if (row !== false) {
            if (!/^\d+$/.test(row) || row < 0 || row > this.row) {
                throw 'replaceLine() failed: invalid row=' + row;
            }
        }
        if (row !== false) {
            this.code[row] = line;
        } else {
            this.code[this.row] = line;
        }
        if (row === false || row == this.row) {
            this.prevCharInit();
        }
    };
    this.prevCharInit = function () {
        this.prevChar = this.code[this.row].charAt(this.code[this.row].length - 1);
    };
    this.writeTab = function () {
        this.write('    ');
        this.prevChar = ' ';
    };
    this.getCurrentLine = function () {
        return this.code[this.row];
    };

    this.symbols1 = '~!^';
    this.symbols2 = '-+*%<=>?:&|/!';
    this.keywords = ['abstract', 'boolean', 'break', 'byte', 'case', 'catch', 'char', 'class',
        'const', 'continue', 'default', 'delete', 'do', 'double', 'else', 'extends', 'false',
        'final', 'finally', 'float', 'for', 'function', 'goto', 'if', 'implements', 'import',
        'in', 'instanceof', 'int', 'interface', 'long', 'native', 'new', 'null', 'package',
        'private', 'protected', 'public', 'return', 'short', 'static', 'super', 'switch',
        'synchronized', 'this', 'throw', 'throws', 'transient', 'true', 'try', 'typeof', 'var',
        'void', 'while', 'with'];
}

if (typeof Array.prototype.indexOf == 'undefined') {
    /* Finds the index of the first occurence of item in the array, or -1 if not found */
    Array.prototype.indexOf = function (item) {
        for (var i = 0; i < this.length; i++) {
            if ((typeof this[i] == typeof item) && (this[i] == item)) {
                return i;
            }
        }
        return -1;
    };
}
if (!String.prototype.trim) {
    String.prototype.trim = function () {
        return this.replace(/^\s*|\s*$/g, '');
    };
}

function str_repeat(str, repeat) {
    ret = '';
    for (var i = 0; i < repeat; i++) {
        ret += str;
    }
    return ret;
}

var debug_w;
function debug(arr, name) {
    if (!debug_w) {
        var width = 600;
        var height = 600;
        var x = (screen.width / 2 - width / 2);
        var y = (screen.height / 2 - height / 2);
        debug_w = window.open('', '', 'scrollbars=yes,resizable=yes,width=' + width + ',height=' + height + ',screenX=' + (x) + ',screenY=' + y + ',left=' + x + ',top=' + y);
        debug_w.document.open();
        debug_w.document.write('<html><head><style>body{margin: 1em;padding: 0;font-family: courier new; font-size: 12px;}h1,h2{margin: 0.2em 0;}</style></head><body><h1>Debug</h1></body></html>');
        debug_w.document.close();
    }
    var ret = '';
    if ('undefined' !== typeof name && name.length) {
        ret = '<h2>' + name + '</h2>' + "\n";
    }
    if ('object' === typeof arr) {
        for (var i = 0; i < arr.length; i++) {
            ret += '[' + i + '] => ' + arr[i] + "\n";
        }
    } else if ('string' == typeof arr) {
        ret += arr;
    } else {
        try { ret += arr.toString(); } catch (e) { }
        ret += ' (' + typeof arr + ')';
    }
    debug_w.document.body.innerHTML += '<pre>' + ret + '</pre>';
}