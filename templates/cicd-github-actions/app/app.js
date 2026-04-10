// Simple application logic
function greet(name) {
    return `Hello, ${name}!`;
}

function add(a, b) {
    return a + b;
}

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    const app = document.getElementById('app');
    app.innerHTML = `<p>${greet('DevOps Engineer')}</p>`;
});

module.exports = { greet, add };
