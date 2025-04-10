class Casacore < Formula
  desc "Suite of C++ libraries for radio astronomy data processing"
  homepage "https://github.com/casacore/casacore"
  url "https://github.com/casacore/casacore/archive/refs/tags/v3.7.1.tar.gz"
  sha256 "ad7ad865d5d8517524bdde71e0083a69442648b693850660dadb0ce6109d91c7"
  head "https://github.com/casacore/casacore.git"

  option "without-python", "Build without Python bindings"

  depends_on "cmake" => :build
  depends_on "casacore-data"
  depends_on "cfitsio"
  depends_on "fftw"
  depends_on "gcc" # for gfortran
  depends_on "gsl"
  depends_on "hdf5"
  depends_on "ncurses"
  depends_on "openblas"
  depends_on "readline"
  depends_on "wcslib"

  if build.with?("python")
    depends_on "python3"
    depends_on "numpy"
    depends_on "boost-python3"
  end

  def install
    casacore_data = HOMEBREW_PREFIX / "opt/casacore-data/data"
    opoo "casacore data not found at #{casacore_data}" unless casacore_data.exist?
    # To get a build type besides "release" we need to change from superenv to std env first
    build_type = "release"
    mkdir "build/#{build_type}" do
      cmake_args = std_cmake_args
      cmake_args.delete "-DCMAKE_BUILD_TYPE=None"
      cmake_args << "-DCMAKE_BUILD_TYPE=#{build_type}"
      cmake_args << "-DBUILD_PYTHON3=#{build.with?("python") ? "ON" : "OFF"}"
      cmake_args << "-DUSE_OPENMP=OFF"
      cmake_args << "-DUSE_FFTW3=ON" << "-DFFTW3_ROOT_DIR=#{HOMEBREW_PREFIX}"
      cmake_args << "-DUSE_HDF5=ON" << "-DHDF5_ROOT_DIR=#{HOMEBREW_PREFIX}"
      cmake_args << "-DBoost_NO_BOOST_CMAKE=True"
      cmake_args << "-DDATA_DIR=#{HOMEBREW_PREFIX / "opt/casacore-data/data"}"
      system "cmake", "../..", *cmake_args
      system "make", "install"
    end
  end

  test do
    system bin / "findmeastable", "IGRF"
    system bin / "findmeastable", "DE405"
  end
end
