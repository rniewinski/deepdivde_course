// nav shadow on scroll
const nav = document.getElementById('nav');
const onScroll = () => nav.classList.toggle('scrolled', window.scrollY > 12);
onScroll();
window.addEventListener('scroll', onScroll, { passive: true });

// code demo tabs
const tabs = document.querySelectorAll('.demo-tab');
const panels = document.querySelectorAll('.demo-panel');
const demoTitle = document.getElementById('demoTitle');
const titles = { orm: 'the_orm.py', sql: 'raw.sql', plan: 'explain.txt' };
tabs.forEach(tab => {
  tab.addEventListener('click', () => {
    const key = tab.dataset.tab;
    tabs.forEach(t => t.classList.toggle('active', t === tab));
    panels.forEach(p => p.classList.toggle('active', p.dataset.panel === key));
    demoTitle.textContent = titles[key];
  });
});

// faq accordion
document.querySelectorAll('.faq-item').forEach(item => {
  const q = item.querySelector('.faq-q');
  const a = item.querySelector('.faq-a');
  q.addEventListener('click', () => {
    const open = item.classList.contains('open');
    document.querySelectorAll('.faq-item').forEach(i => {
      i.classList.remove('open');
      i.querySelector('.faq-a').style.maxHeight = null;
    });
    if (!open) {
      item.classList.add('open');
      a.style.maxHeight = a.scrollHeight + 'px';
    }
  });
});

// scroll to waitlist on invalid form submission (crispy marks invalid fields with .is-invalid)
if (document.querySelector('#waitlist .is-invalid')) {
  document.getElementById('waitlist').scrollIntoView({ behavior: 'smooth' });
}

// scroll reveal: stagger the CSS entrance animation by position.
// Visibility never depends on JS — the animation uses `both` fill and
// ends visible even if this never runs.
document.querySelectorAll('.reveal').forEach((el, i) => {
  el.style.animationDelay = (Math.min(i % 5, 4) * 70) + 'ms';
});
