// Add event listener for the "Play" button
document.getElementById("play").addEventListener("click", function () {
  // Hide the existing content (e.g., the container)
  document.querySelector(".container").style.display = "none";

  // Fetch the play.html content
  fetch("play.html")
    .then((response) => response.text())
    .then((html) => {
      // Insert the HTML into the main-content div
      document.getElementById("main-content").innerHTML = html;

      // Optionally, add logic to reinitialize any JavaScript for the new content
      const script = document.createElement("script");
      script.src = "play.js"; // Dynamically load the play.js script for game logic
      document.body.appendChild(script);
    })
    .catch((err) => console.warn("Failed to load play.html", err));
});
