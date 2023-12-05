let phrases = []; // Contains all of the phrases
let totalTrialNum = 2; // Total number of phrases to be tested
let currTrialNum = 0; // Current trial number
let startTime = 0; // Time starts when the first letter is entered
let finishTime = 0; // Records the time of when the final trial ends
let lettersEnteredTotal = 0; // Running total of the number of letters entered
let lettersExpectedTotal = 0; // Running total of the number of letters expected
let errorsTotal = 0; // Running total of the number of errors
let currentPhrase = ""; // Current target phrase
let currentTyped = ""; // What the user has typed so far
const DPIofYourDeviceScreen = 120;
const sizeOfInputArea = DPIofYourDeviceScreen * 1;
let buttonWidth, buttonHeight;
let pickerX, pickerY, pickerWidth, pickerHeight;
let letterSpaceWidth;
let isDragging = false;
let dragStartX = 0;
let dragStartIndex = 0;
let currentLetterIndex = 0;
let letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
let bottomRowButtons = ["[ ]", "DEL"];
let pickerVisibleLetters = 2;
let pickerLetterCount = 5;

function setup() {
    createCanvas(800, 800);
    textFont('Arial', 20);
    noStroke();
    buttonWidth = sizeOfInputArea / 3;
    buttonHeight = sizeOfInputArea / 3;
    setupPicker();
    // Initialize phrases...
}
function mousePressed() {
    if (overPicker(mouseX, mouseY)) {
        isDragging = true;
        dragStartX = mouseX;
        dragStartIndex = currentLetterIndex;
    }
    // Do not handle button clicks here
}

function mouseDragged() {
    handleMouseDragged();
}

function mouseReleased() {
    handleMouseReleased();
}


function draw() {
    background(255);
    drawPicker();
    drawButtons();
    displayText();
    // Additional drawing logic...
}


function setupPicker() {
    pickerX = width / 2 - sizeOfInputArea / 2;
    pickerY = height / 2 - sizeOfInputArea / 2;
    pickerWidth = buttonWidth * 3;
    pickerHeight = buttonHeight * 2;
    letterSpaceWidth = pickerWidth / pickerLetterCount;
}

function drawPicker() {
    fill(200);
    rect(pickerX, pickerY, pickerWidth, pickerHeight);

    for (let i = -pickerVisibleLetters; i <= pickerVisibleLetters; i++) {
        let letterIndex = (currentLetterIndex + i + letters.length) % letters.length;
        let letterX = pickerX + (i + pickerVisibleLetters) * letterSpaceWidth;

        if (letterIndex === currentLetterIndex) fill(255, 0, 0); // Highlight selected letter
        else fill(0);

        textAlign(CENTER, CENTER);
        text(letters[letterIndex], letterX + letterSpaceWidth / 2, pickerY + pickerHeight / 2);
    }
}

function drawButtons() {
    for (let i = 0; i < bottomRowButtons.length; i++) {
        let x = width / 2 - sizeOfInputArea / 2 + i * 1.5 * buttonWidth;
        let y = height / 2 - sizeOfInputArea / 2 + 2 * buttonHeight;

        if (i === 0) fill(100, 200, 100); // Green for space
        else fill(200, 100, 100); // Red for delete

        rect(x, y, 1.5 * buttonWidth, buttonHeight);
        fill(0);
        textAlign(CENTER, CENTER);
        text(bottomRowButtons[i], x + 0.75 * buttonWidth, y + buttonHeight / 2);
    }
}



function displayText() {
    textAlign(LEFT);
    fill(128);
    text(`Phrase ${currTrialNum + 1} of ${totalTrialNum}`, 70, 50);
    text(`Target:   ${currentPhrase}`, 70, 100);
    text(`Entered:  ${currentTyped}|`, 70, 140);

    // Draw the 'NEXT' button
    fill(255, 0, 0);
    rect(600, 600, 200, 200);
    fill(255);
    text("NEXT >", 650, 650);

    // Additional text display logic (if needed)
}

function mouseClicked() {
    if (overPicker(mouseX, mouseY)) {
        currentTyped += letters[currentLetterIndex];
        console.log("Clicked Letter: " + letters[currentLetterIndex]);
    }

    // Handle space or delete button clicks
    for (let i = 0; i < bottomRowButtons.length; i++) {
        let x = width / 2 - sizeOfInputArea / 2 + i * 1.5 * buttonWidth;
        let y = height / 2 - sizeOfInputArea / 2 + 2 * buttonHeight;
        if (mouseX > x && mouseX < x + 1.5 * buttonWidth && mouseY > y && mouseY < y + buttonHeight) {
            handleBottomRowButtonClick(i);
            break; // Exit the loop once a button is clicked
        }
    }
}


function handleMousePressed() {
    if (overPicker(mouseX, mouseY)) {
        isDragging = true;
        dragStartX = mouseX;
        dragStartIndex = currentLetterIndex;
    } else {
        // Check for button clicks
        for (let i = 0; i < bottomRowButtons.length; i++) {
            let x = width / 2 - sizeOfInputArea / 2 + i * 1.5 * buttonWidth;
            let y = height / 2 - sizeOfInputArea / 2 + 2 * buttonHeight;
            if (mouseX > x && mouseX < x + 1.5 * buttonWidth && mouseY > y && mouseY < y + buttonHeight) {
                handleBottomRowButtonClick(i);
            }
        }
    }
}


function handleBottomRowButtonClick(buttonIndex) {
    if (buttonIndex === 0) {
        // Space button
        currentTyped += " ";
    } else if (buttonIndex === 1) {
        // Delete button
        if (currentTyped.length > 0) {
            currentTyped = currentTyped.substring(0, currentTyped.length - 1);
        }
    }
    console.log("Current Typed: " + currentTyped); // Log the updated string
}

function handleMouseDragged() {
    if (isDragging) {
        let deltaX = mouseX - dragStartX;
        let deltaIndex = Math.round(deltaX / letterSpaceWidth);
        currentLetterIndex = (dragStartIndex - deltaIndex + letters.length) % letters.length;
    }
}

function handleMouseReleased() {
    if (isDragging) {
        isDragging = false;
    }
}

function overPicker(x, y) {
    let pickerLeft = width / 2 - sizeOfInputArea / 2;
    let pickerRight = pickerLeft + pickerWidth;
    let pickerTop = height / 2 - sizeOfInputArea / 2;
    let pickerBottom = pickerTop + pickerHeight;

    return x >= pickerLeft && x <= pickerRight && y >= pickerTop && y <= pickerBottom;
}

