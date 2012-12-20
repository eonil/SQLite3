


export	PRODUCT_NAME="EonilSQLite"
export	SOURCE_DIR="./Classes"




####

export	TARGET_NAME="iOS Static Library"
bash	../../../Scripts/XcodeBuildHelper/2/"Build iOS Framework.bash"

#export	TARGET_NAME="OS X Framework"
#bash	../../../Scripts/XcodeBuildHelper/2/"Build OS X Framework.bash"

#export	TARGET_NAME="OS X Framework"
#bash	../../../Scripts/XcodeBuildHelper/2/"Build OS X Private Framework.bash"

export	TARGET_NAME="OS X Static Library"
bash	../../../Scripts/XcodeBuildHelper/2/"Build OS X Static Framework.bash"



