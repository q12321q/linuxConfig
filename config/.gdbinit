set charset UTF-8
set target-wide-char UTF-16
set print pretty on
set print object on
set print elements 0
set print repeats 1000
# set unwindonsignal on

python
import sys
sys.path.insert(0, '/home/arene/dev/acs-gdb')

import acsprinters
acsprinters.register_printers()

end

python
import sys
sys.path.insert(0, '/home/arene/dev/neolanegdbprettyprint')
from neolane.printers import register_printer_gen
from neolane.commands import DumpBreakpoints

DumpBreakpoints()

class PrintX(gdb.Command):
    def __init__(self):
        super(PrintX, self).__init__('px', gdb.COMMAND_DATA, gdb.COMPLETE_SYMBOL)

    def invoke(self, args, from_tty):
        for i in gdb.string_to_argv(args):
            v = gdb.parse_and_eval(i).__str__().encode('utf-8', 'namereplace')
            gdb.write('Value:\n%s\n' % v.replace("\\n", "\n").replace('\\"','"'))

PrintX()
end

define nlweb
    handle SIGSEGV noprint nostop pass
end
define nonlweb
    handle SIGSEGV print stop nopass
end
define list
    set variable $iter_loop = 0
    set variable $last_print = 0
    while $iter_loop < $arg1
        if $arg0[$iter_loop] != 0
            print $arg0[$iter_loop]
            set variable $last_print = $iter_loop
        end
        if $iter_loop - $last_print >= 1000
            print $iter_loop
            set variable $last_print = $iter_loop
        end
        set variable $iter_loop = $iter_loop + 1
    end
end
document list
list <array name> <array size>
Dump each non-zero element in an array given its name and its size
end
define count_list
    set variable $element_count = 0
    set variable $element = $arg0
    while $element != 0
        set variable $element_count = $element_count + 1
        set variable $element = $element->$arg1
    end
    print $element_count
end
document count_list
count_list <varname> <link field>
Count the number of element in a linked list
end
define f
    set variable $i = 0
    while $i < $arg2
        if $arg0[$i].$arg1 == $arg3
            print $i
            loop_break
        end
        set variable $i = $i + 1
    end
end
define cp
    c
    p $arg0
end
document cp
cp <parameter names>
Continue the program and upon break point reach print the wanted parameter
end
define fork
    set follow-fork-mode parent
end
document cp
fork
Forkt mode
end
