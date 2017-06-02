class Openmodelica < Formula
  desc "Open-source Modelica-based modeling and simulation environment."
  homepage "https://openmodelica.org"
  url "https://github.com/OpenModelica/OpenModelica",
    :using => :git,
    :tag => "v1.11.0"

  bottle do
    root_url "https://mclabservices.di.uniroma1.it/homebrew-science-bottles/"
    sha256 "fe743e6893b436a218797c5d1daf9ab06eef8cb5104dbb475fcc355b737b0c00" => :sierra
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gcc" => :build
  depends_on "boost" => :optional
  depends_on "cmake" => :build
  depends_on "lp_solve"
  depends_on "readline"
  depends_on "omniorb"
  depends_on "gettext" => :build
  depends_on "qt" => "with-qtwebkit"
  depends_on "sundials" => :optional
  depends_on "xz" => :build
  depends_on "gnu-sed" => :build

  def install
    ENV["CC"] = "clang"
    ENV["CXX"] = "clang++"
    args = %W[--disable-debug
              --disable-dependency-tracking
              --disable-silent-rules
              --prefix=#{prefix}
              CC=#{ENV.cc}
              CXX=#{ENV.cxx}
              --with-omniORB=#{Formula["omniorb"].opt_prefix}]
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
    (testpath/"BouncingBall.mo").write <<-EOS.undent
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
    assert File.exist?("BouncingBall")
    system "./BouncingBall"
  end
end
