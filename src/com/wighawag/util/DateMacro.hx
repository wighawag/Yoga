package com.wighawag.util;

import haxe.macro.Expr;
class DateMacro {
    @:macro public static function getFullYear() {
        var date = Std.string(Date.now().getFullYear());
        var pos = haxe.macro.Context.currentPos();
        return { expr : EConst(CString(date)), pos : pos };
    }
}
