
RESOURCES_PATH="Resources/aoc"
RESOURCE_FOLDERS=`ls ${RESOURCES_PATH}`

for folder in ${RESOURCE_FOLDERS}; do
    FILES=`ls "${RESOURCES_PATH}/${folder}"`
    for file in ${FILES}; do
        rm ${RESOURCES_PATH}/${folder}/${file}
    done
    touch ${RESOURCES_PATH}/${folder}/input.txt
    touch ${RESOURCES_PATH}/${folder}/example.1.txt
done

SOURCES_PATH="Sources/aoc"
SOLUTIONS_FILES=`ls ${SOURCES_PATH} | grep 'Solution'`

for file in ${SOLUTIONS_FILES}; do
    rm ${SOURCES_PATH}/${file}

    echo "class ${file%.*}: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    return file.filename
  }

  func solve2() -> String {
    return file.filename
  }
}
" > ${SOURCES_PATH}/${file}
done
