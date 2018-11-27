import java.io.*;
// Running:
// $ javac example.java
// $ java Example [inputfilename]
// If no argument provided, it takes "input.txt"

public class Example {

    public String solve(String filename) {
        String input = readFile(filename);
        //TODO solve
        return input;
    }

    private String readFile(String filename) {
        try(BufferedReader br = new BufferedReader(new FileReader(filename))) {
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();

            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                line = br.readLine();
            }

            return sb.toString();
        } catch (Exception e) {
            System.err.print(e);
            return "Failed";
        }
    }

    public static void main(String[] args) {
        Example sample = new Example();

        String filename;
        if(args.length > 0) {
            filename = args[0];
        } else {
            filename = "input.txt";
        }

        String result = sample.solve(filename);

        System.out.println(result);
    }
}