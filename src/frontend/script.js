function displayErrorMessage(message) {
  const modalContent = document.getElementById("modal-content");
  const errorElement = document.createElement("p");
  errorElement.style.color = "red";
  errorElement.textContent = message;

  // Clear previous content and add error message
  modalContent.innerHTML = "";
  modalContent.appendChild(errorElement);
}

// Function to handle form submission and API request
async function handleFormSubmit(event, endpoint) {
  event.preventDefault();

  console.log("window.location.origin", window.location.origin);
  console.log("endpoint: ", endpoint);
  const baseUrl = "http://localhost:8080"; // Change to the backend’s correct address and port

  const fullEndpoint = `${baseUrl}${endpoint}`;

  const form = event.target;
  const formData = new FormData(form);
  console.log("Full Endpoint:", fullEndpoint); // Log the full endpoint URL

  console.log("formData: ", formData);

  const messageElement = document.getElementById("modal-message");
  console.log("messageElement: ", messageElement);

  const data = Object.fromEntries(formData);
  console.log("data: ", data);
  try {
    const response = await fetch(fullEndpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data),
    });
    console.log("Response Status:", response.status); // Log the status code
    let result;
    try {
      result = await response.json();
      console.log("Success Result:", result);
    } catch (err) {
      console.error("Expected JSON, received something else", err);
      result = {}; // Ensure result is defined even if parsing fails
    }

    if (response.ok) {
      //   const modalContent = document.getElementById("modal-content");
      //   modalContent.innerHTML = `<p>${result.message || "Signup successful! Redirecting..."}</p>`;

      // Display success message without altering the modal's overall structure
      if (messageElement && result && result.message) {
        messageElement.style.color = "white";
        messageElement.innerText = `${result.message || "Signup successful! 🎉 Redirecting..."}`;
      } else {
        console.warn("Element with id 'modal-message' not found in the DOM or result.message is undefined.");
      }

      // Store username in localStorage for easy access across the app
      localStorage.setItem("username", result.username);

      // Hide the form fields only, keeping the modal size consistent
      form.style.display = "none";

      // Close the modal after a delay, to give the user time to read the message
      setTimeout(() => {
        closeModal();
        loadHomeView(); // Load home view on success
      }, 4000); // 2-second delay to show success message
    } else {
      //   // Error message handling
      //   messageElement.style.color = "red";
      //   messageElement.innerText = result.error || "An error occurred. Please try again.";
      //   // Focus back on username if duplicate username error
      //   if (result.error === "Username is already taken.") {
      //     form.querySelector("input[name='username']").focus();
      //   }
      const errorResult = await response.json();
      displayErrorMessage(errorResult.error || "An error occurred.");
    }
  } catch (error) {
    // console.error("Error submitting form:", error);
    // messageElement.style.color = "red";
    // messageElement.innerText = "There was an issue submitting the form. Please try again.";
    console.error("Error submitting form:", error);
    displayErrorMessage("There was an issue submitting the form. Please try again.");
  }
}

// Function to fill the modal content (title and body)
function fillModalContent(templateId, endpoint) {
  const template = document.getElementById(templateId);
  const modalContent = document.getElementById("modal-content");

  // Clear current content
  modalContent.innerHTML = "";

  // Clone and append template content to the modal
  if (template) {
    const content = document.importNode(template.content, true);
    modalContent.appendChild(content);
    // Attach submit event listener to the specific form in the modal
    const form = modalContent.querySelector("form");
    form.addEventListener("submit", (event) => handleFormSubmit(event, endpoint));
  }
}

// Function to open/show the modal (setting visibility and opacity)
function openModal() {
  const modalOverlay = document.getElementById("modal-overlay");
  if (modalOverlay) {
    modalOverlay.style.visibility = "visible";
    modalOverlay.style.opacity = "1";
  }
}

// Function to close/hide the modal
function closeModal() {
  const modalOverlay = document.getElementById("modal-overlay");
  if (modalOverlay) {
    modalOverlay.style.visibility = "hidden";
    modalOverlay.style.opacity = "0";
  }
}

function loadHomeView() {
  // Hide the initial container
  document.getElementById("container").style.display = "none";

  // Show main-content and load the home template
  const mainContent = document.getElementById("main-content");
  mainContent.style.display = "block";
  mainContent.innerHTML = ""; // Clear any existing content

  const template = document.getElementById("home-template");
  if (template) {
    const homeContent = document.importNode(template.content, true);
    mainContent.appendChild(homeContent);

    // Get the username from localStorage and set the greeting message
    const username = localStorage.getItem("username");
    if (username) {
      const greetingElement = document.getElementById("greeting");
      greetingElement.innerHTML = `Hello ${username}! 👋`;
    }

    // Add event listener for the "Play" button
    document.getElementById("play").addEventListener("click", function () {
      const baseUrl = window.location.origin;
      fetch(`${baseUrl}/play.html`)
        .then((response) => response.text())
        .then((html) => {
          mainContent.innerHTML = html;
          const script = document.createElement("script");
          script.src = "play.js";
          document.body.appendChild(script);
        })
        .catch((err) => console.warn("Failed to load play.html", err));
    });

    // Add event listener for the "Three.js" button
    document.getElementById("threejs").addEventListener("click", function () {
      const baseUrl = window.location.origin;
      fetch(`${baseUrl}/threejs_11.html`)
        .then((response) => response.text())
        .then((html) => {
          mainContent.innerHTML = html;
        })
        .catch((err) => console.warn("Failed to load threejs_11.html", err));
    });
  }
}

// Event listeners for buttons to open modals with appropriate content and endpoint
document.getElementById("login-button").addEventListener("click", () => {
  fillModalContent("login-template", "/api/users/login/");
  openModal();
});

document.getElementById("signup-button").addEventListener("click", () => {
  fillModalContent("signup-template", "/api/users/signup/");
  openModal();
});

document.getElementById("close-modal").addEventListener("click", () => {
  closeModal();
});

// Event listener to close modal when clicking outside of it
document.addEventListener("click", (e) => {
  const modalOverlay = document.getElementById("modal-overlay");
  if (e.target === modalOverlay) {
    closeModal();
  }
});

// Cookie check function (commented out for now)
/*
document.addEventListener("DOMContentLoaded", function () {
  if (document.cookie.includes("logincookie")) {
    window.location.href = "/home.html";
  }
});
*/

// Function to create the modal structure if it doesn’t exist
function createAndShowModal() {
  let modalOverlay = document.getElementById("modal-overlay");

  // Create the modal if it doesn't already exist in the DOM
  if (!modalOverlay) {
    modalOverlay = document.createElement("div");
    modalOverlay.id = "modal-overlay";
    modalOverlay.classList.add("modal-overlay");

    modalOverlay.innerHTML = `
		  <div id="modal" class="modal">
			<span id="close-modal" class="close-btn">&times;</span>
			<div id="modal-content" class="modal-content">
			  <!-- Content will be injected here by fillModalContent -->
			</div>
		  </div>
		`;
    document.body.appendChild(modalOverlay); // Add modal to the DOM

    // Event listener to close the modal when clicking the "X"
    document.getElementById("close-modal").addEventListener("click", closeModal);

    // Close the modal when clicking outside the modal content
    modalOverlay.addEventListener("click", (e) => {
      if (e.target === modalOverlay) {
        closeModal();
      }
    });
  }

  // Show the modal
  openModal();
}
