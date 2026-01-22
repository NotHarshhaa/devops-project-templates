// Application JavaScript
document.addEventListener('DOMContentLoaded', function() {
    console.log('🐳 Docker Template App Loaded');
    initializeApp();
});

function initializeApp() {
    // Add smooth scrolling
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Add scroll animations
    observeElements();
}

function showHealth() {
    const healthData = {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime ? `${Math.floor(process.uptime())}s` : 'N/A',
        version: '1.0.0',
        environment: getEnvironment(),
        container: getContainerInfo()
    };

    const modalBody = document.getElementById('modal-body');
    modalBody.innerHTML = `
        <h3>🏥 Application Health</h3>
        <div style="margin-top: 1rem;">
            <p><strong>Status:</strong> <span style="color: green;">✅ ${healthData.status}</span></p>
            <p><strong>Timestamp:</strong> ${healthData.timestamp}</p>
            <p><strong>Uptime:</strong> ${healthData.uptime}</p>
            <p><strong>Version:</strong> ${healthData.version}</p>
            <p><strong>Environment:</strong> ${healthData.environment}</p>
            <p><strong>Container ID:</strong> ${healthData.container.id}</p>
            <p><strong>Docker Version:</strong> ${healthData.container.dockerVersion}</p>
        </div>
        <div style="margin-top: 1.5rem;">
            <h4>🔍 Health Checks</h4>
            <ul style="list-style: none; padding: 0;">
                <li>✅ Application is running</li>
                <li>✅ Static files are accessible</li>
                <li>✅ JavaScript is functional</li>
                <li>✅ CSS is loaded correctly</li>
            </ul>
        </div>
    `;
    
    showModal();
}

function showInfo() {
    const infoData = {
        name: 'Docker Template Application',
        description: 'A production-ready Docker template for modern web applications',
        technologies: ['Docker', 'Nginx', 'HTML5', 'CSS3', 'JavaScript'],
        features: [
            'Multi-stage Docker build',
            'Non-root user security',
            'Health checks',
            'Optimized image size',
            'Environment variables',
            'Docker Compose support'
        ],
        ports: {
            application: 8080,
            nginx: 80,
            monitoring: 9090
        }
    };

    const modalBody = document.getElementById('modal-body');
    modalBody.innerHTML = `
        <h3>📋 Application Information</h3>
        <div style="margin-top: 1rem;">
            <p><strong>Name:</strong> ${infoData.name}</p>
            <p><strong>Description:</strong> ${infoData.description}</p>
            
            <h4 style="margin-top: 1.5rem;">🛠️ Technologies</h4>
            <div style="display: flex; flex-wrap: wrap; gap: 0.5rem; margin-top: 0.5rem;">
                ${infoData.technologies.map(tech => `<span style="background: #e5e7eb; padding: 0.25rem 0.75rem; border-radius: 1rem; font-size: 0.875rem;">${tech}</span>`).join('')}
            </div>
            
            <h4 style="margin-top: 1.5rem;">✨ Key Features</h4>
            <ul style="margin-top: 0.5rem;">
                ${infoData.features.map(feature => `<li>${feature}</li>`).join('')}
            </ul>
            
            <h4 style="margin-top: 1.5rem;">🔌 Ports</h4>
            <ul style="margin-top: 0.5rem;">
                <li>Application: ${infoData.ports.application}</li>
                <li>Nginx Proxy: ${infoData.ports.nginx}</li>
                <li>Monitoring: ${infoData.ports.monitoring}</li>
            </ul>
        </div>
    `;
    
    showModal();
}

function showModal() {
    const modal = document.getElementById('modal');
    modal.style.display = 'block';
    document.body.style.overflow = 'hidden';
}

function closeModal() {
    const modal = document.getElementById('modal');
    modal.style.display = 'none';
    document.body.style.overflow = 'auto';
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('modal');
    if (event.target === modal) {
        closeModal();
    }
}

// Utility functions
function getEnvironment() {
    // In a real application, this would come from environment variables
    return 'production';
}

function getContainerInfo() {
    // Simulated container information
    return {
        id: 'abc123def456',
        dockerVersion: '24.0.0',
        image: 'my-app:latest'
    };
}

// Intersection Observer for scroll animations
function observeElements() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe feature cards and command cards
    document.querySelectorAll('.feature-card, .command-card, .deploy-card').forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(20px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });
}

// Add keyboard navigation
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeModal();
    }
});

// Performance monitoring
window.addEventListener('load', function() {
    const loadTime = performance.now();
    console.log(`🚀 Application loaded in ${loadTime.toFixed(2)}ms`);
    
    // You could send this data to a monitoring service
    if (window.gtag) {
        gtag('event', 'page_load', {
            custom_parameter: loadTime
        });
    }
});
