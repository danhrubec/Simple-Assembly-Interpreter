# Dan Hrubec
# CS 474
# Project 2 - Ruby Assembly Language Interpreter (ALI)

# NOTES
# I have created a few test case files to try out the program on
# input1.txt - sample input that the professor provided on piazza
# input2.txt - a datasize test, it is filled with 300 instructions, which exceeds the limit of 256
# it will output an appropriate error message and exit the program
# input3.txt - almost the same as the sample input in input1.txt, with a small modification that makes it loop indefinitely
# it will prompt the user at 1000 instructions to complete if they wish to continue. The program hard stops at 10,000
# instructions signifying that an infinitely loop has been reached
# input4.txt - tests if the overflow bit is being flagged correctly in add. Adds two numbers that should result in the overflow
# bit being flagged and uses the JVS command to jump to a HLT. It tests the upper bound of the overflow bit
# input5.txt - tests if the overflow bit is being flagged just like in input4.txt, but the lower bound now. Otherwise
# pretty much the same as input4.txt
#
#
# The files must be in the same directory as the rb file. The files must include the file extension ie .txt


# Module that the abstract superclass will include. Pretty much says hey all these functions to resolve the SAL instructions
# must be implemented, or we have this error.
module Resolutions
  def resolveDEC
    fail NotImplementedError, "Method needs to be implemented."
  end
  def resolveLDA
    fail NotImplementedError, "Method needs to be implemented."
  end
  def resolveLDB
    fail NotImplementedError, "Method needs to be implemented."
  end
  def resolveLDI
    fail NotImplementedError, "Method needs to be implemented."
  end
  def resolveSTR
    fail NotImplementedError, "Method needs to be implemented."
  end
  def resolveXCH
    fail NotImplementedError, "Method needs to be implemented."
  end
  def resolveJMP
    fail NotImplementedError, "Method needs to be implemented."
  end
  def resolveJZS
    fail NotImplementedError, "Method needs to be implemented."
  end
  def resolveJVS
    fail NotImplementedError, "Method needs to be implemented."
  end
  def resolveADD
    fail NotImplementedError, "Method needs to be implemented."
  end
  def resolveHLT
    fail NotImplementedError, "Method needs to be implemented."
  end
end

# upgradeable class, or in the case kind of the root class. Holds the arbitrary variables to simulate a virtual machine
# so it has memory which holds all the instructions, regA and regB which are variables holding the value in decimal (allowed per writeup)
# PC which tells us which command we are currently executing, and two boolean flags if the zero bit or the overflow bit has been set. Has no methods
# which is what the simpleinterpreter is for
# Includes the Resolutions module, which will force the the implementation of the resolveSAL commands

class UpgradeableFramebot
  include Resolutions
  @Memory
  @RegA
  @RegB
  @PC
  @ZRBit
  @OFBit

  def initialize
    @Memory = []
    @RegA = 0
    @RegB = 0
    @PC = 0
    @ZRBit = 0
    @OFBit = 0
  end

  #list of abstract methods the interperter MUST implement
  def resolveEZCLAP;
    raise "METHOD HAS NOT BEEN IMPLEMENTED.";
  end
end


# Simple Interpreter will inherit from the upgrableFramebot, and pretty much does all the work with it. It will prompt the user for input,
# whether it be the filename, and the controls during the program's execution.

class SimpleInterpreter < UpgradeableFramebot
  # Class variables. We hold the filename of the file that we are trying to open as it is used throughout other functions
  # Declarations which is an array which holds all the variables we declare ie DEC x DEC y, A parallel array which
  # stores the values at each. An instruction count and a flag when we warn the user when they want to continue or not
  @FileName
  @Delcarations
  @DecValues
  @instructionCount
  @continueWarning

  # no parameters needed in the constructor. We call our superclasses as well as give a default value to all of this class's class variables
  def initialize
    @FileName = ""
    @continueWarning = false
    @instructionCount = 0
    @Declarations = []
    @DecValues = []
    super
  end

  # prompts the user for the filename. This function does not check if the file is valid or not. It in turn calls
  # readFileContents, which then takes the file name and extracts all the data from it.
  def getFileName
    puts "Please enter the filename with the extension, for example (input1.txt)"
    puts "Note that the file must be within the same directory as the ruby file"
    temp = gets.chomp
    @FileName = temp
    puts "Opening the following file: " + @FileName
    readFileContents
  end

  # must be called AFTER getFileName. It tests to see if the file can be read from, and if it encounteres an error,
  # we exit out, nothing more we can do with the program. Rerun to try again. also checks if we reached a max memory size
  # of 256. if we have we also exit as that is a boundary of our "virtual machine" per the project spec
  def readFileContents
    begin
      @Memory = IO.readlines(@FileName)
    rescue
      puts "The file does not exist, is in the wrong directory, or is empty"
      puts "Exiting."
      exit
    end

    if(@Memory.length > 256)
      puts "Memory size exceeded 256. Exiting program. Too many instructions."
      exit
    end
    puts "File contents have been read in successfully"
    # the following code segment outputs the contents of the file
    # i = 0
    # while i < @Memory.length
    # puts @Memory[i]
    # i += 1
    # end
  end

  #End of program report, called when we either reach the end of the file, or when we encounter a HLT command
  # it simply outputs the state of our virtual machine and what each of the piece's values are at, when we reach the end
  # of the instruction set.
  def endOfProgramReport
    puts "###END OF PROGRAM REPORT###"
    puts "Values of declared variables"
    i = 0
    while(i < @Declarations.length)
      puts @Declarations[i].to_s + ": " + @DecValues[i].to_s
      i += 1
    end
    puts "Value of regA: " + @RegA.to_s
    puts "Value of regB: " + @RegB.to_s
    puts "Value of PC: " + @PC.to_s
    puts "Value of zero bit: " + @ZRBit.to_s
    puts "Value of overflow bit: " + @OFBit.to_s

  end

  #simple function to print out the controls. Nothing else to it.
  def printControls
    puts "Please choose an option"
    puts "1 - Executes a single line of the program"
    puts "a - Execute the rest of the program"
    puts "q - Quit"
  end


  #Begin execution will be called in "main" so that we can begin the input loop to run through all the assembly code
  # while we havent reached the end of the file, we either go through 1 line at a time using "1" or just run through it
  # all without the prompts anymore by selecting "a". We can also quit with q
  def beginExecution

    @PC = 0
    while(@PC != @Memory.length)
      printControls
      input = gets.chomp
      if(input == "1")
        puts "1 selected. Executing one line of code."
        puts "\nCurrent command: " + @Memory[@PC].to_s
        decipherCommand(@Memory[@PC])
        @PC += 1
      elsif (input == "a")
        puts "a selected. Completing execution of assembly."
        while(@PC != @Memory.length)
          decipherCommand(@Memory[@PC])
          @PC += 1
          puts "\n"
        end
      elsif (input == "q")
        puts "q selected. Exiting program."
        exit
      else
        puts "Command unknown. Try again please"
      end

    end
    endOfProgramReport
  end

  #Used when changing the value of the declared variables. We would have extracted the
  # symbol that we needed, so we need the index of where we are storing that value, so it is as simple as it gets,
  # goes through our declarations and returns the index of our target. If we dont find it, return -1

  def findIndex(target)

    i = 0
    while(i < @Declarations.length)
      if(target == @Declarations[i])
        return i
      end
      i += 1
    end
    return -1
  end

  #resolves the XCH command. Does a simple swap of the two registers. Uses a temp variable to swap the two registers
  # and then tells the user what the before and after are.

  def resolveXCH
    puts "Before Swap, Register A: " + @RegA.to_s + "\tRegister B: " + @RegB.to_s
    temp = @RegA
    @RegA = @RegB
    @RegB = temp
    puts "After Swap, Register A: " + @RegA.to_s + "\tRegister B: " + @RegB.to_s
  end

  # resolves the HLT command. Tells the user that we reached a HLT, prints the end of program report defined earlier,
  # then exits the program
  #
  def resolveHLT
    puts "HALT. Terminate program execution. Calling report."
    endOfProgramReport
    exit
  end

  # helper function that returns true/false if we would have reached an overflow on a variable. Defines an upper and lower
  # bound, if the number does not go out of the boundaries it will return false. If it does go out of the boundaries, it
  # returns true

  def checkOverflow(testee)
    if(testee > ((2**32) - 1)/2 )
      return true
    elsif(testee < (-1) * 2**31)
      return true
    else
      return false
    end
  end

  # resolves the ADD command. Takes the two registers and simply adds the two values together and puts the resulting number
  # back into regA. If will check after the addition if the zero or overflow bits have been flagged and notify the user.
  def resolveADD
    newVal = @RegA + @RegB
    if(newVal == 0)
      @ZRBit = true
      @OFBit = false
      puts "Zero bit true. Overflow bit false."
    elsif(checkOverflow(newVal) == true)
      @OFBit = true
      @ZRBit = false
      puts "Overflow bit true. Zero bit false."
    else
      @ZRBit = false
      @OFBit = false
      puts "Zero and overflow bits are false."
    end
    @RegA = newVal
    puts "Registers added."
  end

  # resolves the LDA command. Splits up the command into its parts and searches for the symbol in the list of declarations
  # if we do not find it, we exit out of the program. If we do find it, we update RegA to hold its value

  def resolveLDA(command)
    splitString = command.split(' ')
    currSymbol = splitString[1]
    currIndex = findIndex(currSymbol)
    if(currIndex == -1)
      puts "Symbol has not been declared or did not receive a symbol at all. Exiting."
      exit
    end
    @RegA = @DecValues[currIndex]
    puts @RegA.to_s + " has been loaded into regA"

  end

  # resolves the LDB command. Splits up the command into its parts and searches for the symbol in the list of declarations
  # if we do not find it, we exit out of the program. If we do find it, we update RegB to hold its value

  def resolveLDB(command)
    splitString = command.split(' ')
    currSymbol = splitString[1]
    currIndex = findIndex(currSymbol)

    if(currIndex == -1)
      puts "Symbol has not been declared or did not receive a symbol at all. Exiting."
      exit
    end
    @RegB = @DecValues[currIndex]
    puts @RegB.to_s + " has been loaded into regB"
  end

  # Splits up the entire command string, into the DEC and the IDENTIFIER, the indentifier will be stored in
  # splitString[1], then pushes that onto our list of Declarations, as well as giving it an initial value of
  # 0 in our parallel array of DecValues. Notifies the user that the symbol has been declared.

  def resolveDEC(command)
    splitString = command.split(' ')
    newVariable = splitString[1]
    @Declarations.push(newVariable)
    @DecValues.push(0)
    puts newVariable + " has been declared."
  end

  # Starts off by splitting the command into its instruction and its value. Its value is stored in currSymbol, but it is
  # still a string. So we convert that firstly into an integer so we can work with it.
  # Then we simply put that value into regA
  def resolveLDI(command)
    splitString = command.split(' ')
    currSymbol = splitString[1]
    intVal = Integer(currSymbol)
    @RegA = intVal
    puts @RegA.to_s + " has been stored into regA."
  end


  # Again, starts off by splitting the command into its instruction and its symbol. Attempts to find our symbol
  # in our list of declarations. If it does not exist, we exit. We then load that value of the symbol to be equal to
  # whatever was in regA at the time.

  def resolveSTR(command)
    splitString = command.split(' ')
    currSymbol = splitString[1]
    currIndex = findIndex(currSymbol)
    puts currIndex.to_s
    if(currIndex == -1)
      puts "Symbol has not been declared or did not receive a symbol at all. Exiting."
      exit
    end
    @DecValues[currIndex] = @RegA
    temp = @DecValues[currIndex].to_s
    puts temp + " has been loaded into " + @Declarations[currIndex].to_s + "."
  end

  # Starts off by splitting the command into its instruction and its value. Its value is stored in currSymbol, but it is
  # still a string. So we convert that firstly into an integer so we can work with it.
  # Then we simply jump that instruction at the integer. updates PC as well
  def resolveJMP(command)
    splitString = command.split(' ')
    currSymbol = splitString[1]
    intVal = Integer(currSymbol)
    @PC = intVal
    puts "Changing control to instruction at " + @PC.to_s
  end

  # Starts off by splitting the command into its instruction and its value. Its value is stored in currSymbol, but it is
  # still a string. So we convert that firstly into an integer so we can work with it.
  # if the zero bit has been set, then we jump that the instruction number in the command. If it has not been set, we let
  # the user know and continue the execution of the program.
  def resolveJZS(command)
    splitString = command.split(' ')
    currSymbol = splitString[1]
    intVal = Integer(currSymbol)
    if(@ZRBit == true)
      @PC = intVal
      puts "Changing control to instruction at " + @PC.to_s
    else
      puts "Zero bit has not been set. Continuing to next instruction."
    end
  end

  # Starts off by splitting the command into its instruction and its value. Its value is stored in currSymbol, but it is
  # still a string. So we convert that firstly into an integer so we can work with it.
  # if the overflow bit has been set, then we jump that the instruction number in the command. If it has not been set, we let
  # the user know and continue the execution of the program.

  def resolveJVS(command)
    splitString = command.split(' ')
    currSymbol = splitString[1]
    intVal = Integer(currSymbol)
    if(@OFBit == true)
      @PC = intVal
      puts "Changing control to instruction at " + @PC.to_s
    else
      puts "Overflow has not been set. Continuing to next instruction."
    end
  end


  #simply will take the line of instruction and decipher which command needs to be executed whether it is ADD, HLT
  # LDA, etc. It then calls the appropriate resolution function for that specific command. It will also prompt the user
  # if we have reached 1000 instructions completed, if we want to continue going. If the user decides to keep going, the program
  # will execute until we have hit 10,000 commands, where the program force closes in the event of an infinite loop.
  def decipherCommand(line)
    command = line[0..2]
    @instructionCount += 1
    if(@instructionCount > 1000 && @continueWarning == false)
      @continueWarning = true
      puts "You have reached 1000 instructions. The program may be looping infinitely. Continue (y/n)?"
      input = gets.chomp
      if(input == "y")
        puts "Continue. Warning cleared."
      else
        puts "Exiting."
        exit
      end
    end
    if(@instructionCount > 10000)
      puts "10,000 commands reached. Force closing the program."
      exit
    end
    if(command == "DEC")
      #puts "Declare detected"
      resolveDEC(line)
    elsif(command == "LDA")
      #puts "Load Data byte into Accumulator"
      resolveLDA(line)
    elsif(command == "LDB")
      #puts "Loads byte at data memory address symbol into B"
      resolveLDB(line)
    elsif(command == "LDI")
      #puts "Loads the integer value into the accumulator register. Can be negative"
      resolveLDI(line)
    elsif(command == "STR")
      #puts "Stores Content of accumulator into data memory at address of symbol"
      resolveSTR(line)
    elsif(command == "XCH")
      #puts "Exchanges the content registers A and B."
      resolveXCH
    elsif(command == "JMP")
      #puts "Transfers control to instruction at address number in program memory"
      resolveJMP(line)
    elsif(command == "JZS")
      #puts "Transfers control to instruction at address number if the zero-result bit is set."
      resolveJZS(line)
    elsif(command == "JVS")
      #puts "Transfer control to instruction at address number if the overflow bit is set"
      resolveJVS(line)
    elsif(command == "ADD")
      #puts "Adds regA and regB. Sum stored into regA. The overflow and zero-result bits are updated accordingly."
      resolveADD
    elsif(command == "HLT")
      resolveHLT
    else
      puts "Unknown command in file. Exiting."
      exit
    end
    puts "\n"
  end

end

# creates the new object and begins the flow the program.
si7agent = SimpleInterpreter.new
si7agent.getFileName
si7agent.beginExecution


