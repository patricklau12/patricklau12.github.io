import java.util.Arrays;
//import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 120; //you will need to look up the DPI or PPI of your device to make sure you get the right scale. Or play around with this value.
final float sizeOfInputArea = DPIofYourDeviceScreen * 1; //aka, 1.0 inches square!
PImage watch;
PImage finger;

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

///////////
///////////
///////////
//////////
////////////
//////////
//////////
float buttonWidth = sizeOfInputArea / 3;
float buttonHeight = sizeOfInputArea / 3;
String[] buttonLabels = {"abc", "def", "ghi","jkl", "mno","pqr", "stu","vwx", "yz"};

boolean isDetailedView = false;
int detailedViewIndex = -1; // Index of the button pressed to enter detailed view

String[][] detailedViewLabels = {
    {"<-", "<-", "<-", "a", "b", "c", "[ ]", "", "del"} ,
    {"<-", "<-", "<-", "d", "e", "f", "[ ]", "", "del"} ,
    {"<-", "<-", "<-", "g", "h", "i", "[ ]", "", "del"} ,
    {"<-", "<-", "<-", "j", "k", "l", "[ ]", "", "del"} ,
    {"<-", "<-", "<-", "m", "n", "o", "[ ]", "", "del"} ,
    {"<-", "<-", "<-", "p", "q", "r", "[ ]", "", "del"} ,
    {"<-", "<-", "<-", "s", "t", "u", "[ ]", "", "del"} ,
    {"<-", "<-", "<-", "v", "w", "x", "[ ]", "", "del"} ,
    {"<-", "<-", "<-", "y", "z", "", "[ ]", "", "del"} ,
};

// Scrollable picker variables
String[] letters = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"};
String[] bottomRowButtons = {"[ ]", "DEL"};

int pickerVisibleLetters = 2; // Number of letters to display on either side of the current letter
// Variables for scrollable picker
int pickerLetterCount = 5; // Total number of letters to display at once
int currentLetterIndex = 0; // Index of the currently highlighted letter
float pickerX, pickerY, pickerWidth, pickerHeight; // Position and size of picker
float letterSpaceWidth; // Width allocated for each letter in the picker
boolean isDragging = false; // Flag to track if the user is dragging the picker
float dragStartX = 0; // X position where the last drag started
int dragStartIndex = 0; // Index of the letter when the last drag started


boolean overPicker(float x, float y) {
  // The picker occupies the first two rows and three columns
  float pickerLeft = width / 2 - sizeOfInputArea / 2;
  float pickerRight = pickerLeft + buttonWidth * 3;
  float pickerTop = height / 2 - sizeOfInputArea / 2;
  float pickerBottom = pickerTop + buttonHeight * 2;

  // Check if the x and y coordinates are within the bounds of the picker
  return x >= pickerLeft && x <= pickerRight && y >= pickerTop && y <= pickerBottom;
}


//You can modify anything in here. This is just a basic implementation.
void setup()
{
    //noCursor();
    watch = loadImage("watchhand3smaller.png");
    //finger = loadImage("pngeggSmaller.png"); //not using this
    phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
    //Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
    //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
    
    //orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
    size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
    textFont(createFont("Arial", 20)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
    noStroke(); //my code doesn't use any strokes
    
    setupPicker();
    
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
    background(255); //clear background
    
    if (startTime != 0) {
        
    }
    
    //check to see if the user finished. You can't change the score computation.
    if (finishTime!= 0)
        {
        fill(0);
        textAlign(CENTER);
        text("Trials complete!",400,200); //output
        text("Total time taken: " + (finishTime - startTime),400,220); //output
        text("Total letters entered: " + lettersEnteredTotal,400,240); //output
        text("Total letters expected: " + lettersExpectedTotal,400,260); //output
        text("Total errors entered: " + errorsTotal,400,280); //output
        float wpm = (lettersEnteredTotal / 5.0f) / ((finishTime - startTime) / 60000f); //FYI - 60K is number of milliseconds in minute
        text("Raw WPM: " + wpm,400,300); //output
        float freebieErrors = lettersExpectedTotal * .05; //no penalty if errors are under 5% of chars
        text("Freebie errors: " + nf(freebieErrors,1,3),400,320); //output
        float penalty = max(errorsTotal - freebieErrors, 0) *.5f;
        text("Penalty: " + penalty,400,340);
        text("WPM w/ penalty: " + (wpm - penalty),400,360); //yes, minus, because higher WPM is better
        return;
    }
    
    drawWatch(); //draw watch background
    fill(100);
    rect(width / 2 - sizeOfInputArea / 2, height / 2 - sizeOfInputArea / 2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"
    
    
    if (startTime ==  0 & !mousePressed)
        {
        fill(128);
        textAlign(CENTER);
        text("Click to start time!", 280, 150); //display this messsage until the user clicks!
    }
    
    if (startTime ==  0 & mousePressed)
        {
        nextTrial(); //start the trials!
    }
    
    if (startTime!= 0)
        {
        //feel free to change the size and position of the target/entered phrases and next button 
        textAlign(LEFT); //align the text left
        fill(128);
        text("Phrase" + (currTrialNum + 1) + " of " + totalTrialNum, 70, 50); //draw the trial count
        fill(128);
        text("Target:   " + currentPhrase, 70, 100); //draw the target string
        text("Entered:  " + currentTyped + "|", 70, 140); //draw what the user has entered thus far 
        
        //draw very basic next button
        fill(255, 0,0);
        rect(600, 600, 200, 200); //draw next button
        fill(255);
        text("NEXT >", 650, 650); //draw next label
        
    }
    
    
    //drawFinger(); //no longer needed as we'll be deploying to an actual touschreen device
    
    //Starting position
    float startX = width / 2 - sizeOfInputArea / 2;
    float startY = height / 2 - sizeOfInputArea / 2;
    
    // Update buttonlabels based on state
    if (isDetailedView) {
        // Set labels for the current detailed view
        buttonLabels = detailedViewLabels[detailedViewIndex];
    } else {
        // Set labels for default view
        buttonLabels = new String[]{"abc", "def", "ghi", "jkl", "mno", "pqr", "stu", "vwx", "yz"};
    }
    
    drawPicker(); // Draw the letter picker

   // Drawing the space and delete buttons
    for (int i = 0; i < bottomRowButtons.length; i++) {
        float x = width / 2 - sizeOfInputArea / 2 + i * 1.5 * buttonWidth;
        float y = height / 2 - sizeOfInputArea / 2 + 2 * buttonHeight;

        // Set different colors for each button
        if (i == 0) fill(100, 200, 100); // Green for Space
        else fill(200, 100, 100); // Red for Delete

        rect(x, y, 1.5 * buttonWidth, buttonHeight); // Button size adjusted to 1.5 columns
        fill(0); // Text color
        textAlign(CENTER, CENTER);
        text(bottomRowButtons[i], x + 0.75 * buttonWidth, y + buttonHeight / 2); // Centering text in the expanded button area
    }

    
}

void setupPicker() {
    // Initialize picker variables, call this from setup()
    pickerX = width / 2 - sizeOfInputArea / 2;
    pickerY = height / 2 - sizeOfInputArea / 2;
    pickerWidth = buttonWidth * 3;
    pickerHeight = buttonHeight * 2; // Using first two rows
    letterSpaceWidth = pickerWidth / pickerLetterCount;
}


void drawPicker() {
    fill(200);
    rect(pickerX, pickerY, pickerWidth, pickerHeight);

    int arrayLength = letters.length;
    for (int i = -pickerVisibleLetters; i <= pickerVisibleLetters; i++) {
        int letterIndex = (currentLetterIndex + i) % arrayLength;
        if (letterIndex < 0) letterIndex += arrayLength;

        float letterX = pickerX + (i + pickerVisibleLetters) * letterSpaceWidth;

        if (letterIndex == currentLetterIndex) fill(255, 0, 0); // Highlight color for current letter
        else fill(0); // Normal color for other letters

        textAlign(CENTER, CENTER);
        text(letters[letterIndex], letterX + letterSpaceWidth / 2, pickerY + pickerHeight / 2);
    }
}


void handleSwipe(float deltaX) {
    // Convert the swipe delta into a change in letter index
    int deltaIndex = round(deltaX / (buttonWidth / 3));
    
    // Update the current letter index and clamp it withinbounds
    currentLetterIndex += deltaIndex;
    currentLetterIndex = constrain(currentLetterIndex, 0, letters.length - 1);
}

void handleScroll(float delta) {
    // Adjust the current letter index based on the scroll delta
    currentLetterIndex += delta;
    if (currentLetterIndex < 0) {
        currentLetterIndex = 0; // Prevent scrolling before A
    } else if (currentLetterIndex >= letters.length) {
        currentLetterIndex = letters.length - 1; // Prevent scrolling past Z
    }
}

//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
    {
    return(mouseX > x && mouseX<x + w && mouseY>y && mouseY<y + h); //check to see if it is in button bounds
}

void mousePressed() {
    if (overPicker(mouseX, mouseY)) {
        isDragging = true;
        dragStartX = mouseX;
        dragStartIndex = currentLetterIndex;
    } else {
        // Handle other mousePressed events
    }
}

void mouseDragged() {
    if (isDragging) {
        float deltaX = mouseX - dragStartX;
        int deltaIndex = int(deltaX / letterSpaceWidth);
        currentLetterIndex = (dragStartIndex - deltaIndex) % letters.length;
        
        // Wrap around logic
        if (currentLetterIndex < 0) {
            currentLetterIndex += letters.length;
        }
    }
}

void mouseReleased() {
    //Check if the user was dragging
    if(isDragging) {
        // If dragging just ended, stop dragging but don't snap back to start
        isDragging = false;
} else {
        // Check if the click was within the picker area
        if (overPicker(mouseX, mouseY)) {
           // Append the current letter to the typed string
            currentTyped += letters[currentLetterIndex];
        }
}
}



void nextTrial()
    {
    if (currTrialNum >= totalTrialNum) //check to see if experiment is done
        return; //if so, just return
    
    if (startTime!= 0 && finishTime ==  0) //in the middle of trials
        {
        println("==================");
        println("Phrase " + (currTrialNum + 1) + " of " + totalTrialNum); //output
        println("Target phrase: " + currentPhrase); //output
        println("Phrase length: " + currentPhrase.length()); //output
        println("User typed: " + currentTyped); //output
        println("User typed length: " + currentTyped.length()); //output
        println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
        println("Time taken on this trial: " + (millis() - lastTime)); //output
        println("Time taken since beginning: " + (millis() - startTime)); //output
        println("==================");
        lettersExpectedTotal += currentPhrase.trim().length();
        lettersEnteredTotal += currentTyped.trim().length();
        errorsTotal += computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
    }
    
    //probably shouldn't need to modify any of this output / penalty code.
    if (currTrialNum == totalTrialNum - 1) //check to see if experiment just finished
        {
        finishTime = millis();
        println("==================");
        println("Trials complete!"); //output
        println("Total time taken: " + (finishTime - startTime)); //output
        println("Total letters entered: " + lettersEnteredTotal); //output
        println("Total letters expected: " + lettersExpectedTotal); //output
        println("Total errors entered: " + errorsTotal); //output
        
        float wpm = (lettersEnteredTotal / 5.0f) / ((finishTime - startTime) / 60000f); //FYI - 60K is number of milliseconds in minute
        float freebieErrors = lettersExpectedTotal *.05; //no penalty if errors are under 5% of chars
        float penalty = max(errorsTotal - freebieErrors, 0) * .5f;
        
        println("Raw WPM: " + wpm); //output
        println("Freebie errors: " + freebieErrors); //output
        println("Penalty: " + penalty);
        println("WPM w/ penalty: " + (wpm - penalty)); //yes, minus, becuase higher WPM is better
        println("==================");
        
        currTrialNum++; //increment by one so this mesage only appears once when all trials are done
        return;
    }
    
    if (startTime ==  0) //first trial starting now
        {
        println("Trials beginning! Starting timer..."); //output we're done
        startTime = millis(); //start the timer!
    } 
    else
        currTrialNum++; //increment trial number
    
    lastTime = millis(); //record the time of when this trial ended
    currentTyped = ""; //clear what is currently typed preparing for next trial
    currentPhrase = phrases[currTrialNum]; // load the next phrase!
    //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

//probably shouldn't touch this - should be same for all teams.
void drawWatch()
    {
    float watchscale = DPIofYourDeviceScreen / 138.0; //normalizes the image size
    pushMatrix();
    translate(width / 2, height / 2);
    scale(watchscale);
    imageMode(CENTER);
    image(watch, 0, 0);
    popMatrix();
}

//probably shouldn't touch this - should be same for all teams.
void drawFinger()
    {
    float fingerscale = DPIofYourDeviceScreen / 150f; //normalizes the image size
    pushMatrix();
    translate(mouseX, mouseY);
    scale(fingerscale);
    imageMode(CENTER);
    image(finger,52,341);
    if (mousePressed)
        fill(0);
    else
        fill(255);
    ellipse(0,0,5,5);
    
    popMatrix();
}


//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!== = = = = = = = = = = = = 
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
    {
    int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];
    
    for (int i = 0; i <= phrase1.length(); i++)
        distance[i][0] = i;
    for (int j = 1; j <= phrase2.length(); j++)
        distance[0][j] = j;
    
    for (int i = 1; i <= phrase1.length(); i++)
        for (int j = 1; j <= phrase2.length(); j++)
            distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));
    
    return distance[phrase1.length()][phrase2.length()];
}

////////////////
/////////////
/////////////
/////////////

void mouseClicked() {
    if (overPicker(mouseX, mouseY)) {
        currentTyped += letters[currentLetterIndex];
        println("Clicked Letter: " + letters[currentLetterIndex]); // Print to console
        println("Current Typed: " + currentTyped); // Print updated string to console
    }

    // Handling clicks on the space and delete buttons
    for (int i = 0; i < bottomRowButtons.length; i++) {
        float x = width / 2 - sizeOfInputArea / 2 + i * 1.5 * buttonWidth;
        float y = height / 2 - sizeOfInputArea / 2 + 2 * buttonHeight;
        if (mouseX > x && mouseX < x + 1.5 * buttonWidth && mouseY > y && mouseY < y + buttonHeight) {
            handleBottomRowButtonClick(i);
        }
    }
}


void handleBottomRowButtonClick(int buttonIndex) {
    if (buttonIndex == 0) {
        // Space button
        currentTyped += " ";
    } else if (buttonIndex == 1) {
        // Delete button
        if (currentTyped.length() > 0) {
            currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
        }
    }
    println("Current Typed: " + currentTyped); // Print updated string to console
}