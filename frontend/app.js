const API = 'http://localhost:3000';

async function checkHealth() {
  const badge = document.getElementById('statusBadge');
  try {
    const res = await fetch(`${API}/health`);
    if (res.ok) {
      badge.textContent = '✅ API Online';
      badge.className = 'badge online';
    }
  } catch {
    badge.textContent = '❌ API Offline';
    badge.className = 'badge offline';
  }
}

async function loadItems() {
  const loading = document.getElementById('loading');
  const emptyMsg = document.getElementById('emptyMsg');
  const list = document.getElementById('itemList');
  const count = document.getElementById('count');

  loading.style.display = 'block';
  emptyMsg.style.display = 'none';
  list.innerHTML = '';

  try {
    const res = await fetch(`${API}/items`);
    const items = await res.json();

    loading.style.display = 'none';
    count.textContent = items.length;

    if (items.length === 0) {
      emptyMsg.style.display = 'block';
      return;
    }

    list.innerHTML = items.map(item => `
      <li>
        <span>${escapeHtml(item.name)}</span>
        <button class="delete-btn" onclick="deleteItem('${item._id}')">🗑 Delete</button>
      </li>
    `).join('');
  } catch (err) {
    loading.textContent = '⚠️ Could not load items. Is the backend running?';
  }
}

async function addItem() {
  const input = document.getElementById('itemInput');
  const btn = document.getElementById('addBtn');
  const name = input.value.trim();

  if (!name) { input.focus(); return; }

  btn.disabled = true;
  btn.textContent = 'Adding...';

  try {
    const res = await fetch(`${API}/items`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name })
    });
    if (res.ok) {
      input.value = '';
      await loadItems();
    } else {
      alert('Failed to add item.');
    }
  } catch {
    alert('Cannot connect to backend.');
  } finally {
    btn.disabled = false;
    btn.textContent = 'Add';
    input.focus();
  }
}

async function deleteItem(id) {
  try {
    await fetch(`${API}/items/${id}`, { method: 'DELETE' });
    await loadItems();
  } catch {
    alert('Failed to delete item.');
  }
}

function escapeHtml(str) {
  return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

// Allow Enter key to add item
document.addEventListener('DOMContentLoaded', () => {
  document.getElementById('itemInput').addEventListener('keydown', e => {
    if (e.key === 'Enter') addItem();
  });
  checkHealth();
  loadItems();
});
