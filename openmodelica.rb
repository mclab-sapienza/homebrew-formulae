class Openmodelica < Formula
  desc "Open-source Modelica-based modeling and simulation environment"
  homepage "https://openmodelica.org"
  url "https://github.com/OpenModelica/OpenModelica",
    :using => :git,
    :tag => "v1.12.0",
    :revision => "2d85c3abb8486d728ffcbd3201095cf2552d8e47"

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
  depends_on "omniorb"
  depends_on "open-mpi"
  depends_on "readline"
  depends_on "boost" => :optional
  depends_on "sundials" => :optional

  def install
    args = %W[--disable-debug
              --disable-dependency-tracking
              --disable-silent-rules
              --prefix=#{prefix}
              --with-omniORB=#{Formula["omniorb"].opt_prefix}
              CXXFLAGS=-stdlib=libc++
              LDFLAGS=-stdlib=libc++]
    args << "--with-cppruntime" if build.with? "boost"
    ohai "Checking out branch master for libraries submodule."
    cd("libraries") do
      system "git", "checkout", "master"
    end
    opoo "OMOptim will not be installed, because of compilation issues."
    inreplace "Makefile.in", /^omoptim:.*$/, ""
    inreplace "Makefile.in", /^.*OMOptim$/, ""
    system "autoconf"
    system "./configure", *args
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
