


export	PRODUCT_NAME="EonilSQLite"
export	SOURCE_DIR="./Classes"


export	TARGET_NAME="iOS Static Library"
bash	../../../Scripts/XcodeBuildHelper/2/"Build iOS Framework.bash"

exit 0


export	TARGET_NAME="OS X Framework"
export	PRODUCT_NAME="EonilCocoaSupplementary"
bash	../../Scripts/XcodeBuildHelper/"Build OS X Framework.bash"

export	TARGET_NAME="OS X Framework"
export	PRODUCT_NAME="EonilCocoaSupplementary"
bash	../../Scripts/XcodeBuildHelper/"Build OS X Private Framework.bash"

export	TARGET_NAME="OS X Static Library"
export	PRODUCT_NAME="EonilCocoaSupplementary"
bash	../../Scripts/XcodeBuildHelper/"Build OS X Static Framework.bash"