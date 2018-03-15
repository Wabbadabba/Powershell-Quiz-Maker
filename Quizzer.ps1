<#
.SYNOPSIS
Multiple choice Quiz generator. 

.Description
Quizzer creates a multiple choice test utilizing a multidimensional array to hold the data. There are currently no parameters, and must be dot (.) initiated or run in the ISE.

.Example
PS C:\Users\Temp\Documents\PS testing> . '.\Quiz 2_0.ps1'

.Notes
Author:   Wabbadabba
Email:    wabbadabbo@gmail.com

Version History:
2.0 - 13 March 2018
    - Randomized Answer bank for each question. Added in comments
1.0 - September 
    - Initial Development, Randomized questions, but static answer choices.  

#>

function Get-Quiz{
	$Questions = @()
	$data = Import-Csv ".\QuestionText.csv"

	foreach($item in $data){
		$QuestionText = $item.('Question')
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

	#cls 

	$letter = ('A: ', 'B: ', 'C: ', 'D: ')

	#Randomizes Question List
	$Questions = $Questions | Sort-Object {Get-Random}

	$questionCount = 0
	$correctCount = 0

	# Displays each question and answer choices
	foreach ($question in $Questions)
	{
		$question.Answers = $question.Answers | Sort-Object {Get-Random}
		$question.Question
		$L = 0
		$answerArray = @()
		foreach ($Item in $question.Answers)
		{
			$output = $letter[$L] + $Item
			$output
			$answerArray += $output
			$L++
		}

		# Resetting $L to 0, allowing for reuse of this variable.
		$L = 0
    
		foreach ($entry in $answerArray)
		{
			# write-host $answerArray[0] -Foregroundcolor "yellow"
			if ($answerArray[$L] -match $question.CorrectAnswer)
			{
				$correctLetter = $answerArray[$L][0]
				#write-host "DEBUG: Correct Letter $correctLetter" -Foregroundcolor "yellow"
				#write-host "DEBUG: Array Slot $L" -Foregroundcolor "yellow"
			   $L++
			}
			else
			{
				$correctLetter = $correctLetter
				$L++
			}
		}
    
		$answer = Read-Host "Answer"
    
		# Resolves whether or not the question is correct, outputs appropriate information
		if ($answer.ToUpper() -match $correctLetter)
		{
			write-host "Correct! `n" -foregroundcolor "green"
			"----------------------------------------------------------------------- `n"
			$questionCount++
			$correctCount++
		}
		else
		{
			write-host "Incorrect!" -foregroundcolor "red "
        
			"Correct Answer was: " + $correctLetter

			# I personally like giving the correct answer when a wrong answer is given
			"(Chosen Response: " + $answer.ToUpper() + ")"+ " `n "
			"----------------------------------------------------------------------- `n"

			$questionCount++
		}
	}

	# Final statistics and score.
	$percentageRight =  $correctCount / $questionCount  * 100

	''
	"Out of $questionCount, you got $correctCount questions correct! `n"

	if ($percentageRight -ge 75)
	{
		write-host "    You got a $percentageRight%!! `n" -ForegroundColor "green"
		'Congradulations! You Passed the Practice Exam!!!'
	}
		else
		{
			write-host "    You got a $percentageRight%!! `n" -ForegroundColor "red"
			'Unfortunately, you were unable to meet the minimum score of 75%, please try again'
		}
}

