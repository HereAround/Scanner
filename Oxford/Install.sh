echo ""
echo "------------------------------------------------------------------------"
echo "Welcome!"
echo "This is an automated script to install SheafCohomologiesOnToricVarieties"
echo "https://github.com/homalg-project/SheafCohomologyOnToricVarieties"
echo "(*) Tested for Debian 9 and Ubuntu 18.04 (16/03/2020)"
echo "(*) No warrenty for other operating systems"
echo "(*) Superuser rights required"
echo "------------------------------------------------------------------------"
echo ""


echo "------------------------------------------------------------------------"
echo "Step1: Install dependencies shipped with Ubuntu/Debian"
echo "------------------------------------------------------------------------"
echo ""
echo "(*) htop"
echo "(*) autoconf"
echo "(*) build-essential"
echo "(*) libgmp-dev"
echo "(*) libtool"
echo "(*) git"
echo "(*) libatlas-base-dev"
echo "(*) libatlas-dev"
echo "(*) liblapack-dev"
echo "(*) screen"
echo "(*) libcdd-dev"
echo "(*) 4ti2"
echo "(*) singular"
echo ""

sudo apt-get install htop autoconf build-essential libgmp-dev libtool git libatlas-base-dev libblas-dev liblapack-dev screen libcdd-dev 4ti2 singular

echo ""
echo ""
echo "------------------------------------------------------------------------"
echo "Step2: Install gap"
echo "------------------------------------------------------------------------"
echo ""

echo "(*) Download gap 4.10.2"
echo ""
curl -O https://www.gap-system.org/pub/gap/gap-4.10/tar.gz/gap-4.10.2.tar.gz
tar xf gap-4.10.2.tar.gz

echo ""
echo "(*) Configure and install gap"
echo ""
cd gap-4.10.2
./configure --with-gmp=system
make -j4

echo ""
echo "(*) Test installation of gap"
echo ""
touch tester.gi
echo 'Read( Filename( DirectoriesLibrary( "tst" ), "testinstall.g" ) );' >> tester.gi
./gap tester.gi
rm tester.gi

echo ""
echo "(*) Configure packages shipped with gap"
echo ""
cd bin/
./BuildPackages.sh
cd ..

echo ""
echo "(*) Install IO-package"
echo ""
cd pkg/io*
./configure
make -j4
cd ../..

echo ""
echo "(*) Prepare folder /local/pkg to store latest version of SheafCohomologies"
mkdir local
cd local/
mkdir pkg
cd ..

echo "(*) Add this folder to search path of gap"
cd bin/
sed -i '$ d' gap.sh
echo 'exec "$GAP_EXE/gap" -l "$GAP_DIR/local;$GAP_DIR" "$@"' >> gap.sh
cd ..

echo "(*) Make gap executable by just typing 'gap' into the terminal"
sudo cp bin/gap.sh /usr/bin/gap

echo ""
echo ""
echo "------------------------------------------------------------------------"
echo "Step3: Download gap packages from github"
echo "------------------------------------------------------------------------"
echo ""

cd local/pkg/

echo "(*) Clone AutoDoc"

git clone https://github.com/homalg-project/AutoDoc.git
cd AutoDoc
git reset --hard 573359e2ae0cf78cdcf958512491c9c4aec04447
cd ..

echo""
echo "(*) Clone CAP_project"

git clone https://github.com/homalg-project/CAP_project.git
cd CAP_project
git reset --hard e307b000639297bc91b48720f3c92cf6a3a0c293
cd ..

echo ""
echo "(*) Clone CddInterface"

git clone https://github.com/homalg-project/CddInterface.git
cd CddInterface
git reset --hard a4ca998b630bb8974655d933ca0a52eec1b5b99a
cd ..

echo ""
echo "(*) Clone ComplexesForCAP"
git clone https://github.com/homalg-project/ComplexesForCAP.git
cd ComplexesForCAP
git reset --hard 4a9fd3fa05e815e465df719284573f7bc1609900
cd ..

echo ""
echo "(*) Clone homalg_project"

git clone https://github.com/homalg-project/homalg_project.git
cd homalg_project
git reset --hard 74337def45def6e2ef9b89dcc92f931633fbdb35
cd ..

echo ""
echo "(*) Clone LessGenerators"

git clone https://github.com/homalg-project/LessGenerators.git
cd LessGenerators
git reset --hard 9d93bbd66a0e72f4ac649ffc88e25f92307e727d
cd ..

echo ""
echo "(*) Clone NConvex"

git clone https://github.com/homalg-project/NConvex.git
cd NConvex
git reset --hard 54eb7e97eea194917c5344ea6060df174d444c66
cd ..

echo ""
echo "(*) Clone PrimaryDecomposition"

git clone https://github.com/homalg-project/PrimaryDecomposition.git
cd PrimaryDecomposition
git reset --hard 35586160803534bb5930400952947aabca744fa4
cd ..

echo ""
echo "(*) Clone QPA2"

git clone https://github.com/homalg-project/QPA2.git
cd QPA2
git reset --hard b5467696b6929e28ac86ba31c213ea629962ff40
cd ..

echo ""
echo "(*) Clone SingularForHomalg"

git clone https://github.com/homalg-project/SingularForHomalg.git
cd SingularForHomalg
git reset --hard bd4e30e09c22cdf0b5431cb2a18e9df7e58e450b
cd ..

echo ""
echo "(*) Clone TriangulatedCategoriesForCAP"

git clone https://github.com/homalg-project/TriangulatedCategoriesForCAP.git
cd TriangulatedCategoriesForCAP
git reset --hard 32ad6e7115dfcd8ef7a1ab54c183f4eede58971c
cd ..

echo ""
echo "(*) Clone NormalizInterface"

git clone https://github.com/gap-packages/NormalizInterface.git
cd NormalizInterface
git reset --hard cd69a42b2b3f554ebe0946212bf93302abfc8b21 
cd ..

echo ""
echo "(*) Clone SheafCohomologyOnToricVarieties"

git clone https://github.com/homalg-project/SheafCohomologyOnToricVarieties
cd SheafCohomologyOnToricVarieties
git reset --hard 5f2be41c528cefd2c5aaf0604ceb2445d68e4a8f
cd ..

echo "(*) Cloning complete"


echo ""
echo ""
echo "------------------------------------------------------------------------"
echo "Step4: Install gap packages"
echo "------------------------------------------------------------------------"
echo ""

echo "(*) Install Gauss"
echo ""
cd homalg_project/Gauss/
./configure ../../../../
make -j4
cd ../..

echo ""
echo "(*) Install CddInterface"
echo ""
cd CddInterface/
./install.sh ../../..
cd ..

echo ""
echo "(*) Install NormalizInterface"
echo ""
cd NormalizInterface/
./build-normaliz.sh ../../..
./autogen.sh ../../..
./configure --with-gaproot=../../..
make -j4
cd


echo ""
echo ""
echo "------------------------------------------------------------------------"
echo "Step5: Install Spasm and configure SpasmInterface"
echo "------------------------------------------------------------------------"
echo ""

echo "(*) Download development version of Spasm"
echo ""
git clone https://github.com/HereAround/spasm.git
cd spasm
git checkout -b martin_devel
git pull origin martin_devel

echo ""
echo "(*) Install Spasm"
echo ""
aclocal
autoconf
autoreconf --install
./configure
make -j4

echo ""
echo "(*) Configure SpasmInterface"
echo ""
cd bench/
touch set.gi
echo 'LoadPackage( "SpasmInterface" );' >> set.gi
echo 'path := DirectoriesSystemPrograms();;' >> set.gi
echo 'pwd := Filename( path, "pwd" );;' >> set.gi
echo 'stdin := InputTextUser();;' >> set.gi
echo 'str := "";;' >> set.gi
echo 'stdout := OutputTextString(str,true);;' >> set.gi
echo 'String ( Process( DirectoryCurrent(), pwd, stdin, stdout, [] ) );;' >> set.gi
echo 'SetSpasmDirectory( str );' >> set.gi
echo 'QUIT;;' >> set.gi
gap set.gi
rm set.gi
cd ../..


echo ""
echo ""
echo "------------------------------------------------------------------------"
echo "Step6: Test installation"
echo "------------------------------------------------------------------------"
echo ""

echo "Test SheafCohomologiesOnToricVarieties"
cd gap-4.10.2/local/pkg/SheafCohomologyOnToricVarieties/SheafCohomologyOnToricVarieties/
gap makedoc.g
gap maketest.g

