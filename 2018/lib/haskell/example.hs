import System.IO
import Control.Monad

main = do  
    contents <- readFile "input.txt"
    print . lines $ contents
-- alternately, main = print . map readInt . words =<< readFile "test.txt"
-- let liness = lines =<< readFile "input.txt"
--     putStrLn liness
readInt :: String -> String
readInt = read