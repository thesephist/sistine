// dark mode toggle

const darkModeButton = document.createElement('button');
darkModeButton.textContent = 'Dark';
darkModeButton.classList.add('darkModeButton');
darkModeButton.addEventListener('click', () => {
    darkModeButton.textContent = document.body.classList.contains('dark') ? 'Dark' : 'Light';
    document.body.classList.toggle('dark');
});

const rightNav = document.querySelector('.right-nav');
rightNav.insertBefore(darkModeButton, rightNav.children[0]);

