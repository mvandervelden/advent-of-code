import java.io.File
import java.io.InputStream

// Running:
// $ kotlinc example.kt -include-runtime -d example.jar
// $ java -jar example.jar [inputfilename]

class Solver {
    fun solve(filename: String): String {
        val input = readFile(filename)
        //TODO solve
        return input
    }

    private fun readFile(filename: String): String {
        val lineList = mutableListOf<String>()
	    File(filename).useLines { lines -> lines.forEach { lineList.add(it) }}
        return lineList.joinToString(separator = "\n")
    }
}

fun main(args: Array<String>) {
    val solver = Solver()
    val result: String
    if (args.size > 0) {
        result = solver.solve(args[0])
    } else {
        result = solver.solve("input.txt")
    }

    println(result)
}