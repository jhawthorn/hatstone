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

append_cppflags("-I$(srcdir)/capstone/include")
append_cppflags("-I$(srcdir)/capstone/include/capstone")

append_cppflags("-D CAPSTONE_HAS_ARM")
append_cppflags("-D CAPSTONE_HAS_ARM64")
append_cppflags("-D CAPSTONE_HAS_X86")
append_cppflags("-D CAPSTONE_DIET_NO")

create_makefile('hatstone')
