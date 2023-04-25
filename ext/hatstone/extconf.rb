require 'mkmf'

$VPATH << "$(srcdir)/capstone"
Dir.chdir(__dir__) do
  $srcs = []
  $srcs.concat Dir['capstone/*.c'].sort

  architectures = Dir.glob("capstone/arch/**").map { |x| File.basename(x) }
  architectures.each do |arch|
    $VPATH << "$(srcdir)/capstone/arch/#{arch}"
    $srcs.concat Dir["capstone/arch/#{arch}/**/*.c"].sort
  end

  $srcs.map! { |n| File.basename(n) }
end

$srcs << "hatstone.c"

$CPPFLAGS << " -I$(srcdir)/capstone/include "
$CPPFLAGS << " -I$(srcdir)/capstone/include/capstone "
$CPPFLAGS << " -D CAPSTONE_HAS_ARM "
$CPPFLAGS << " -D CAPSTONE_HAS_ARM64 "
$CPPFLAGS << " -D CAPSTONE_HAS_X86 "
$CPPFLAGS << " -D CAPSTONE_DIET_NO "
$CPPFLAGS << " -D CAPSTONE_STATIC "

$CFLAGS << " -fvisibility=hidden "

create_makefile('hatstone')
