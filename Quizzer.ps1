Function Invoke-Quizzer{
<#
.SYNOPSIS
	Multiple choice Quiz generator. 
.Description
	Quizzer creates a multiple choice test utilizing a multidimensional array to hold the data.
.NOTES

    To function, quizzes must be in a folder '/quizzes/', which should on the same level as Quizzer.ps1.

    Any additional CSVs must formatted with the headers: QuestionText,Answer1,Answer2,Answer3,Answer4,CorrectAnswer

    Dynamic number of answer choices to be featured in a future update.

	Author:   Wabbadabba
	Email:    wabbadabbo@gmail.com

	----------------
    Version History:
    ----------------
    3.0 - 07 April 2018
        - Menu UI Added, allowing for settings to be altered without the use of Parameters

	2.1 - 18 March 2018
		- Added Parameters to change various details of execution

	2.0 - 13 March 2018
		- Randomized Answer bank for each question. Added in comments

	1.0 - September 2017
		- Initial Development, Randomized questions, but static answer choices.  
#>

    Clear-Host
    ### Displays Title Card ### 
    $asciiArt = @"
  ______      __    __   __   ________   ________   _______ .______      
 /  __  \    |  |  |  | |  | |       /  |       /  |   ____||   _  \     
|  |  |  |   |  |  |  | |  | '---/  /   '---/  /   |  |__   |  |_)  |    
|  |  |  |   |  |  |  | |  |    /  /       /  /    |   __|  |      /     
|  '--'  '--.|  '--'  | |  |   /  /----.  /  /----.|  |____ |  |\  \----.
 \_____\_____\\______/  |__|  /________| /________||_______|| _| '._____|
                                                                         
"@
    $border = "-------------------------------------------------------------------------"
    Write-host $border -ForegroundColor Yellow
    Write-host $asciiArt -ForegroundColor Red
    Write-host $border`n -ForegroundColor Yellow
    Write-Host "Welcome to Quizzer! `n`nFor information on quiz editing and customization, please check out 'Get-Help Quizzer -Full'`n" -ForegroundColor Cyan

    $response = Write-Menu -Menu (ls $PsScriptRoot\quizzes -name) -Header "QUIZ SELECTION`n--------------" -Prompt "`nPlease select an option"  -TextColor Green -AddExit
    $path = $PsScriptRoot + "\quizzes\" + $response

    if ($response -eq "Exit"){
        Write-host "EXITING..." -ForegroundColor Red
        exit
    }else {
        
        Get-Quiz -source $path
        }
}

Function Write-Menu
{

<#
.SYNOPSIS
	Display custom menu in the PowerShell console.
.DESCRIPTION
	The Write-Menu cmdlet creates numbered and colored menues
	in the PS console window and returns the choiced entry.
.PARAMETER Menu
	Menu entries.
.PARAMETER PropertyToShow
	If your menu entries are objects and not the strings
	this is property to show as entry.
.PARAMETER Prompt
	User prompt at the end of the menu.
.PARAMETER Header
	Menu title (optional).
.PARAMETER Shift
	Quantity of <TAB> keys to shift the menu items right.
.PARAMETER TextColor
	Menu text color.
.PARAMETER HeaderColor
	Menu title color.
.PARAMETER AddExit
	Add 'Exit' as very last entry.
.EXAMPLE
	PS C:\> Write-Menu -Menu "Open","Close","Save" -AddExit -Shift 1
	Simple manual menu with 'Exit' entry and 'one-tab' shift.
.EXAMPLE
	PS C:\> Write-Menu -Menu (Get-ChildItem 'C:\Windows\') -Header "`t`t-- File list --`n" -Prompt 'Select any file'
	Folder content dynamic menu with the header and custom prompt.
.EXAMPLE
	PS C:\> Write-Menu -Menu (Get-Service) -Header ":: Services list ::`n" -Prompt 'Select any service' -PropertyToShow DisplayName
	Display local services menu with custom property 'DisplayName'.
.EXAMPLE
	PS C:\> Write-Menu -Menu (Get-Process |select *) -PropertyToShow ProcessName |fl
	Display full info about choicen process.
.INPUTS
	Any type of data (object(s), string(s), number(s), etc).
.OUTPUTS
	[The same type as input object] Single menu item.
.NOTES
	Author      :: Roman Gelman @rgelman75
	Version 1.0 :: 21-Apr-2016 :: [Release] :: Publicly available
	Version 1.1 :: 03-Nov-2016 :: [Change] :: Supports a single item as menu entry
	Version 1.2 :: 22-Jun-2017 :: [Change] :: Throws an error if property, specified by -PropertyToShow does not exist. Code optimization
	Version 1.3 :: 27-Sep-2017 :: [Bugfix] :: Fixed throwing an error while menu entries are numeric values
.LINK
	https://ps1code.com/2016/04/21/write-menu-powershell
#>    
	[CmdletBinding()]
	[Alias("menu")]
	Param (
		[Parameter(Mandatory, Position = 0)]
		[Alias("MenuEntry", "List")]
		$Menu
		 ,
		[Parameter(Mandatory = $false, Position = 1)]
		[string]$PropertyToShow = 'Name'
		 ,
		[Parameter(Mandatory = $false, Position = 2)]
		[ValidateNotNullorEmpty()]
		[string]$Prompt = 'Pick a choice'
		 ,
		[Parameter(Mandatory = $false, Position = 3)]
		[Alias("Title")]
		[string]$Header = ''
		 ,
		[Parameter(Mandatory = $false, Position = 4)]
		[ValidateRange(0, 5)]
		[Alias("Tab", "MenuShift")]
		[int]$Shift = 0
		 ,
		[Parameter(Mandatory = $false, Position = 5)]
		[Alias("Color", "MenuColor")]
		[System.ConsoleColor]$TextColor = 'White'
		 ,
		[Parameter(Mandatory = $false, Position = 6)]
		[System.ConsoleColor]$HeaderColor = 'Yellow'
		 ,
		[Parameter(Mandatory = $false)]
		[ValidateNotNullorEmpty()]
		[Alias("Exit", "AllowExit")]
		[switch]$AddExit
	)
	
	Begin
	{
		$ErrorActionPreference = 'Stop'
		if ($Menu -isnot [array]) { $Menu = @($Menu) }
		if ($Menu[0] -is [psobject] -and $Menu[0] -isnot [string])
		{
			if (!($Menu | Get-Member -MemberType Property, NoteProperty -Name $PropertyToShow)) { Throw "Property [$PropertyToShow] does not exist" }
		}
		$MaxLength = if ($AddExit) { 8 }
		else { 9 }
		$AddZero = if ($Menu.Length -gt $MaxLength) { $true }
		else { $false }
		[hashtable]$htMenu = @{ }
	}
	Process
	{
		### Write menu header ###
		if ($Header -ne '') { Write-Host $Header -ForegroundColor $HeaderColor }
		
		### Create shift prefix ###
		if ($Shift -gt 0) { $Prefix = [string]"`t" * $Shift }
		
		### Build menu hash table ###
		for ($i = 1; $i -le $Menu.Length; $i++)
		{
			$Key = if ($AddZero)
			{
				$lz = if ($AddExit) { ([string]($Menu.Length + 1)).Length - ([string]$i).Length }
				else { ([string]$Menu.Length).Length - ([string]$i).Length }
				"0" * $lz + "$i"
			}
			else
			{
				"$i"
			}
			
			$htMenu.Add($Key, $Menu[$i - 1])
			
			if ($Menu[$i] -isnot 'string' -and ($Menu[$i - 1].$PropertyToShow))
			{
				Write-Host "$Prefix[$Key] $($Menu[$i - 1].$PropertyToShow)" -ForegroundColor $TextColor
			}
			else
			{
				Write-Host "$Prefix[$Key] $($Menu[$i - 1])" -ForegroundColor $TextColor
			}
		}
		
		### Add 'Exit' row ###
		if ($AddExit)
		{
			[string]$Key = $Menu.Length + 1
			$htMenu.Add($Key, "Exit")
			Write-Host "$Prefix[$Key] Exit" -ForegroundColor $TextColor
		}
		
		### Pick a choice ###
		Do
		{
			$Choice = Read-Host -Prompt $Prompt
			$KeyChoice = if ($AddZero)
			{
				$lz = if ($AddExit) { ([string]($Menu.Length + 1)).Length - $Choice.Length }
				else { ([string]$Menu.Length).Length - $Choice.Length }
				if ($lz -gt 0) { "0" * $lz + "$Choice" }
				else { $Choice }
			}
			else
			{
				$Choice
			}
		}
		Until ($htMenu.ContainsKey($KeyChoice))
	}
	End
	{
		return $htMenu.get_Item($KeyChoice)
	}
	
} #EndFunction Write-Menu

Function Get-Quiz{

<#
.SYNOPSIS
	Multiple choice Quiz generator. 
.Description
	Quizzer creates a multiple choice test utilizing a multidimensional array to hold the data.
.PARAMETER Source
	The path to the quiz bank source. The default behavior to ".\QuestionText.csv"
.PARAMETER Grade
	Alter's the passing score. Default value is 75.
.PARAMETER Size
	Alter the number of questions presented during execution. Default behavior is 10.

#>
    [CmdletBinding()]
	Param(
		[string]
		$source,

		[int]
		$grade = 75,

		[int]
		$size = 10

	)
	$Questions = @()
	$data = Import-Csv $source
	$letter = ('A: ', 'B: ', 'C: ', 'D: ')
    $bool = "true"

        ### Parses Source CSV ### 
        foreach($item in $data){
		    $QuestionText = $item.('QuestionText')
		    $Answer1 = $item.('Answer1')
		    $Answer2 = $item.('Answer2')
		    $Answer3 = $item.('Answer3')
		    $Answer4 = $item.('Answer4')
		    $Correctanswer = $item.('CorrectAnswer')

		    $Questions += [pscustomobject]@{
			    Question = $QuestionText;
			    Answers = (
				    $Answer1,
				    $Answer2,
				    $Answer3,
				    $Answer4
			    )
			    CorrectAnswer = $Correctanswer

		    }

	    }

        $qLength = $Questions.length
        While ($bool -eq "true") {
            Quiz-Stats -source $source -grade $grade -size $size -maxSize $qLength
            $edit = Write-Menu -Menu "Edit Passing Grade", "Edit Number of Questions", "Start Quiz", "Back" -Header "`nOptions`n-------" -Prompt "`nPlease make a selection " -TextColor Green

            if($edit -eq "Edit Passing Grade"){
                $oGrade = $grade
                $grade = Read-Host "Please input new Passing Grade (Between 1 and 100)"
                if ($grade -lt 1 -or $grade -gt 100){
                    Write-Host "Invalid Score (MUST BE BETWEEN 1 AND 100)" -ForegroundColor Red
                    $grade = $oGrade
                }
            }elseif ($edit -eq "Edit Number of Questions"){
                [string]$size = Read-Host "Please input a Number of Questions in the quiz (Cannot go below 1, type 'Max' for all questions in bank)"
                if ($size -eq "Max"){
                    [int]$size = $qlength
                }
                if ($size -lt 1 ){
                    Write-Host "Invalid Response" -ForegroundColor Red
                }
            }elseif ($edit -eq "Back"){
                Invoke-Quizzer
            }elseif($edit -eq "Start Quiz"){
                $bool = "false"
                Write-Host "`n-------------`nSTARTING QUIZ`n-------------" -ForegroundColor Yellow
            }
        }

	    ### Randomizes Question List ###
	    $Questions = $Questions | Sort-Object {Get-Random} | Select-Object -First $size

	    $questionCount = 0
	    $correctCount = 0
            $displayNumber = 1

	    ### Outputs questions and answer choices ###
	    foreach ($question in $Questions){
		    $question.Answers = $question.Answers | Sort-Object {Get-Random}
		    Write-host `n$displayNumber") " $question.Question`n
		    $L = 0
		    $answerArray = @()
		    $displayNumber++
		    foreach ($Item in $question.Answers){
			    $output = $letter[$L] + $Item
			    $output
			    $answerArray += $output
			    $L++
		    }

		    $L = 0
    
            ### Pairs CorrectAnswer with an answer choice ###
		    foreach ($entry in $answerArray){
			    if ($answerArray[$L] -match $question.CorrectAnswer){
				    $correctLetter = $answerArray[$L][0]
			       $L++
			    }
			    else{
				    $correctLetter = $correctLetter
				    $L++
			    }
		    }
    
		    $answer = Read-Host "Answer"

		### Resolves whether or not the question is correct, outputs response ###
		if ($answer.ToUpper() -match $correctLetter){
			write-host "Correct! `n" -foregroundcolor "green"
			"----------------------------------------------------------------------- `n"
			$questionCount++
			$correctCount++
		}
		else{
			write-host "Incorrect!" -foregroundcolor "red "
        
			"Correct Answer was: " + $correctLetter

			# I personally like giving the correct answer when a wrong answer is given
			"(Chosen Response: " + $answer.ToUpper() + ")"+ " `n "
			"----------------------------------------------------------------------- `n"

			$questionCount++
		}
	}

	### Final statistics and score ###
	$percentageRight =  $correctCount / $questionCount  * 100

	''
	"Out of $questionCount, you got $correctCount questions correct! `n"

	if ($percentageRight -ge $grade){
		write-host "    You got a $percentageRight%!! `n" -ForegroundColor "green"
		'Congradulations! You Passed the Practice Exam!!!'
	}
		else{
			write-host "    You got a $percentageRight%!! `n" -ForegroundColor "red"
			'Unfortunately, you were unable to meet the minimum score of ' + $grade + '%, please try again'
		}
}#EndFunction Get-Quiz

Function Quiz-Stats{
    Param(
		[string]
		$source,

		[int]
		$grade,

		[int]
		$size,

        [int]
        $maxSize
	)
    Write-Host "`nQUIZ STATISTICS`n---------------" -ForegroundColor Yellow
    $stats = @" 
File: $source
Passing Score: $grade
Number of Questions: $size
Quiz Bank Size: $maxSize
"@
    Write-Host $stats -ForegroundColor Cyan
}


