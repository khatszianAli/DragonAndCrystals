class ConsoleView{
    func display(_ message: String){
        print(message)
    }
    
    func readCmd() -> String{
        print("\nВведите команду (N, S, W, E, get [item], drop [item], eat [item] open chest):")
        return readLine() ?? ""
    }
}
