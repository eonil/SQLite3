


export	PRODUCT_NAME="EonilSQLite"
export	SOURCE_DIR="./Classes"
export	PACKAGE_DIR="Package"
export	BUILD_CONFIG="Release"

export	TARGET_NAME="iOS Static Library"
bash	../../../Scripts/XcodeBuildHelper/2/"Build iOS Framework.bash"

#export	TARGET_NAME="OS X Framework"
#bash	../../../Scripts/XcodeBuildHelper/2/"Build OS X Framework.bash"

#export	TARGET_NAME="OS X Framework"
#bash	../../../Scripts/XcodeBuildHelper/2/"Build OS X Private Framework.bash"

export	TARGET_NAME="OS X Static Library"
bash	../../../Scripts/XcodeBuildHelper/2/"Build OS X Static Framework.bash"







export	PRODUCT_NAME="EonilSQLite"
export	SOURCE_DIR="./Classes"
export	PACKAGE_DIR="Package-Debug"
export	BUILD_CONFIG="Debug"

export	TARGET_NAME="iOS Static Library"
bash	../../../Scripts/XcodeBuildHelper/2/"Build iOS Framework.bash"

#export	TARGET_NAME="OS X Framework"
#bash	../../../Scripts/XcodeBuildHelper/2/"Build OS X Framework.bash"

#export	TARGET_NAME="OS X Framework"
#bash	../../../Scripts/XcodeBuildHelper/2/"Build OS X Private Framework.bash"

export	TARGET_NAME="OS X Static Library"
bash	../../../Scripts/XcodeBuildHelper/2/"Build OS X Static Framework.bash"



