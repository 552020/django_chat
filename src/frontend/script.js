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

document.getElementById("threejs").addEventListener("click", function () {
  // Fetch the Three.js HTML content from Vite's dev server (running on port 3000)
  fetch("http://localhost:3000/threejs_11.html") // Adjust this path based on Vite's setup
    .then((response) => response.text())
    .then((html) => {
      // Insert the fetched HTML into the main-content div (or any target container)
      document.getElementById("main-content").innerHTML = html;
      // No need to dynamically add <script> tag, it's already in the fetched HTML
    })
    .catch((err) => console.warn("Failed to load threejs_11.html", err));
});
