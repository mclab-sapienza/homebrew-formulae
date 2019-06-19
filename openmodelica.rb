class Openmodelica < Formula
  desc "Open-source Modelica-based modeling and simulation environment"
  homepage "https://openmodelica.org"
  url "https://github.com/OpenModelica/OpenModelica",
    :using => :git,
    :tag => "v1.13.2",
    :revision => "cd9628b7af26430dd72a5eb5a8381e57a18df975"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "cmake" => :build
  depends_on "gnu-sed" => :build
  depends_on "libtool" => :build
  depends_on "qt@5.5" => :build
  depends_on "xz" => :build
  depends_on "gcc"
  depends_on "gettext"
  depends_on "hwloc"
  depends_on "lp_solve"
  depends_on "open-mpi"
  depends_on "readline"
  depends_on "boost" => :optional
  depends_on "sundials" => :optional

  patch :p0, :DATA

  def install
    args = %W[--disable-debug
              --disable-dependency-tracking
              --disable-silent-rules
              --prefix=#{prefix}
              --without-omniORB
              --disable-omnotebook
              --disable-modelica3d
              --without-paradiseo]
    args << "--with-cppruntime" if build.with? "boost"
    # opoo "OMOptim will not be installed, because of compilation issues."
    # inreplace "Makefile.in", /^omoptim:.*$/, ""
    # inreplace "Makefile.in", /^.*OMOptim$/, ""
    inreplace "OMCompiler/3rdParty/graphstream/gs-netstream/c++/src/netstream-socket.cpp", /bind/, "::bind"
    system "autoconf"
    system "./configure",
              "CXXFLAGS=-stdlib=libc++ -std=c++11",
              "CPPFLAGS=-stdlib=libc++",
              "LDFLAGS=-stdlib=libc++",
              *args
    system "make"
    system "make", "install", "INSTALL_APPDIR=#{prefix}"
  end

  test do
    (testpath/"BouncingBall.mo").write <<-EOS
model BouncingBall "The 'classic' bouncing ball model"
  type Height=Real(unit="m");
  type Velocity=Real(unit="m/s");
  parameter Real e=0.8 "Coefficient of restitution";
  parameter Height h0=1.0 "Initial height";
  Height h;
  Velocity v;
initial equation
  h = h0;
equation
  v = der(h);
  der(v) = -9.81;
  when h<0 then
    reinit(v, -e*pre(v));
  end when;
end BouncingBall;
EOS
    system "#{bin}/omc", "-s", testpath/"BouncingBall.mo"
    system "make", "-f", "BouncingBall.makefile"
    system "./BouncingBall"
  end
end
__END__
*** OMPlot/common/m4/qmake.m4.orig	2019-06-18 12:42:37.000000000 +0200
--- OMPlot/common/m4/qmake.m4	2019-06-18 12:42:20.000000000 +0200
*************** if test -n "$QMAKE"; then
*** 43,48 ****
--- 43,49 ----
        sed "s/-arch@<:@\\@:>@* i386//g" | \
        sed "s/-arch@<:@\\@:>@* x86_64//g" | \
        sed "s/-arch//g" | \
+       sed "s/\$(arch)//g" | \
        sed "s/-Xarch@<:@^ @:>@*//g" > $MAKEFILE.fixed && \
        mv $MAKEFILE.fixed $MAKEFILE' >> qmake.sh
      QMAKE="sh `pwd`/qmake.sh"
*** OMCompiler/configure.ac.orig	2019-06-18 23:04:46.000000000 +0200
--- OMCompiler/configure.ac	2019-06-18 23:17:19.000000000 +0200
*************** fi
*** 267,282 ****

  fi

- else # Is Darwin
-
- AC_LANG_PUSH([C++])
- OLD_CXXFLAGS=$CXXFLAGS
- for flag in -stdlib=libstdc++; do
-   CXXFLAGS="$OLD_CXXFLAGS $flag"
-   AC_TRY_LINK([], [return 0;], [LDFLAGS_LIBSTDCXX="$flag"],[CXXFLAGS="$OLD_CXXFLAGS"])
- done
- AC_LANG_POP([C++])
-
  fi

  m4_include([common/m4/ax_cxx_compile_stdcxx_11.m4])
--- 267,272 ----
*** OMPlot/qwt/Makefile.unix.in.orig	2019-06-19 14:45:21.000000000 +0200
--- OMPlot/qwt/Makefile.unix.in	2019-06-19 15:25:15.000000000 +0200
*************** all: build
*** 14,20 ****

  Makefile: qwt.pro
  	@rm -f $@
! 	$(QMAKE) QMAKE_CXX=@CXX@ QMAKE_CXXFLAGS="@CXXFLAGS@" QMAKE_LINK="@CXX@" qwt.pro
  clean:
  	test ! -f Makefile || $(MAKE) -f Makefile clean
  	rm -rf build lib Makefile
--- 14,20 ----

  Makefile: qwt.pro
  	@rm -f $@
! 	$(QMAKE) QMAKE_CXX=@CXX@ QMAKE_CXXFLAGS="@CXXFLAGS@" QMAKE_LFLAGS="@LDFLAGS@" QMAKE_LINK="@CXX@" qwt.pro
  clean:
  	test ! -f Makefile || $(MAKE) -f Makefile clean
  	rm -rf build lib Makefile
