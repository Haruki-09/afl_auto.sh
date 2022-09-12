Command line used to find this crash:

afl-fuzz -i /home/kosuge/afl-auto/In -o /home/kosuge/afl-auto/result/2022_09_11_20:11/Out/ece934f3d1205dfb82a2922cd8128f6120621f09 -f input.c /home/kosuge/ctags-link/ctags input.c

If you can't reproduce a bug outside of afl-fuzz, be sure to set the same
memory limit. The limit used for this fuzzing session was 50.0 MB.

Need a tool to minimize test cases before investigating the crashes or sending
them to a vendor? Check out the afl-tmin that comes with the fuzzer!

Found any cool bugs in open-source tools using afl-fuzz? If yes, please drop
me a mail at <lcamtuf@coredump.cx> once the issues are fixed - I'd love to
add your finds to the gallery at:

  http://lcamtuf.coredump.cx/afl/

Thanks :-)
