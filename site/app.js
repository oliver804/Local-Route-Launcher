'use strict';
const preview = document.querySelector('#app-preview');
const appearanceButtons = document.querySelectorAll('[data-appearance]');
const picker = document.querySelector('[data-download-picker]');
const english = document.documentElement.lang === 'en';
let platform = 'mac';
let appearance = 'dark';

function renderPreview() {
  if (!preview) return;
  const source = platform === 'mac'
    ? preview.dataset[appearance]
    : preview.getAttribute(`data-windows-${appearance}`);
  preview.src = source;
  preview.closest('a').href = source;
  const system = platform === 'mac' ? 'macOS' : 'Windows';
  preview.alt = english
    ? `Local Route Launcher ${system} in ${appearance} appearance: proxy settings, launch controls and connection checks`
    : `Local Route Launcher ${system} ${appearance === 'dark' ? '深色' : '浅色'}界面：代理设置、启动控制与连接检查`;
  document.querySelector('.preview-toolbar > span').textContent = english
    ? `${system} preview · light / dark`
    : `${system} 界面预览 · 深浅外观`;
  document.querySelector('.product-stage figcaption').textContent = english
    ? `${system} interface · Rendered with sample diagnostic data`
    : `${system} 应用界面 · 使用示例诊断数据渲染`;
}

if (preview) {
  appearanceButtons.forEach((button) => {
    button.addEventListener('click', () => {
      appearance = button.dataset.appearance;
      appearanceButtons.forEach((item) => item.setAttribute('aria-pressed', String(item === button)));
      renderPreview();
    });
  });
}

if (picker) {
  const tabs = [...picker.querySelectorAll('[data-platform]')];
  const macDownload = picker.querySelector('[data-mac-download]');
  const windowsDownload = picker.querySelector('[data-windows-download]');
  const variantButton = picker.querySelector('.download-variant');
  const variantLabel = picker.querySelector('[data-variant-label]');
  const menu = picker.querySelector('.download-options');
  const choices = [...menu.querySelectorAll('[data-variant]')];
  const requirements = picker.querySelector('[data-platform-requirements]');
  let variant = 'arm64';

  function closeMenu() {
    menu.hidden = true;
    variantButton.setAttribute('aria-expanded', 'false');
  }

  function renderPicker() {
    tabs.forEach((tab) => tab.setAttribute('aria-pressed', String(tab.dataset.platform === platform)));
    macDownload.hidden = platform !== 'mac';
    windowsDownload.hidden = platform !== 'windows';
    variantButton.hidden = platform !== 'mac';
    if (platform !== 'mac') closeMenu();
    const selected = choices.find((choice) => choice.dataset.variant === variant);
    macDownload.href = selected.href;
    macDownload.setAttribute('aria-label', english
      ? `Download for macOS ${variant === 'arm64' ? 'Apple Silicon' : 'Intel'}`
      : `下载 macOS ${variant === 'arm64' ? 'Apple Silicon' : 'Intel'} 版本`);
    variantLabel.textContent = `.dmg · ${variant === 'arm64' ? 'Apple Silicon' : 'Intel'}`;
    choices.forEach((choice) => {
      const active = choice === selected;
      if (active) choice.setAttribute('aria-current', 'true');
      else choice.removeAttribute('aria-current');
      choice.querySelector('span').textContent = active ? '✓' : '';
    });
    requirements.textContent = platform === 'windows'
      ? 'Windows 10 1809+ / 11 · x64'
      : `macOS 13+ · ${variant === 'arm64' ? 'Apple Silicon' : 'Intel'}`;
    renderPreview();
  }

  tabs.forEach((tab) => tab.addEventListener('click', () => {
    platform = tab.dataset.platform;
    renderPicker();
  }));
  variantButton.addEventListener('click', () => {
    menu.hidden = !menu.hidden;
    variantButton.setAttribute('aria-expanded', String(!menu.hidden));
  });
  choices.forEach((choice) => choice.addEventListener('click', (event) => {
    event.preventDefault();
    variant = choice.dataset.variant;
    closeMenu();
    renderPicker();
    variantButton.focus();
  }));
  document.addEventListener('pointerdown', (event) => {
    if (!picker.contains(event.target)) closeMenu();
  });
  picker.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && !menu.hidden) {
      closeMenu();
      variantButton.focus();
    }
  });
  renderPicker();
}
