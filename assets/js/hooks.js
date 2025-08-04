// Phoenix LiveView Hooks for Widget System

export const Sortable = {
  mounted() {
    // Simple drag and drop implementation
    let draggedElement = null;
    
    const items = this.el.querySelectorAll('.sortable-item');
    
    items.forEach(item => {
      // Make items draggable
      item.draggable = true;
      
      // Add drag start handler
      item.addEventListener('dragstart', (e) => {
        draggedElement = item;
        item.classList.add('dragging');
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/html', item.innerHTML);
      });
      
      // Add drag end handler
      item.addEventListener('dragend', (e) => {
        item.classList.remove('dragging');
      });
      
      // Add drag over handler
      item.addEventListener('dragover', (e) => {
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
        
        const afterElement = getDragAfterElement(this.el, e.clientY);
        if (afterElement == null) {
          this.el.appendChild(draggedElement);
        } else {
          this.el.insertBefore(draggedElement, afterElement);
        }
      });
    });
    
    // Helper function to determine where to insert
    const getDragAfterElement = (container, y) => {
      const draggableElements = [...container.querySelectorAll('.sortable-item:not(.dragging)')];
      
      return draggableElements.reduce((closest, child) => {
        const box = child.getBoundingClientRect();
        const offset = y - box.top - box.height / 2;
        
        if (offset < 0 && offset > closest.offset) {
          return { offset: offset, element: child };
        } else {
          return closest;
        }
      }, { offset: Number.NEGATIVE_INFINITY }).element;
    };
    
    // Add drop handler to notify server of new order
    this.el.addEventListener('drop', (e) => {
      e.preventDefault();
      
      // Get new order
      const items = [...this.el.querySelectorAll('.sortable-item')];
      const order = items.map(item => item.dataset.id || item.dataset.index);
      
      // Push event to server
      const field = this.el.dataset.group || this.el.dataset.field;
      this.pushEvent(`reorder_${field}`, { order: order });
    });
  }
};

// Confirmation Dialog Hook
export const ConfirmDialog = {
  mounted() {
    const dialogId = this.el.dataset.actionId;
    const title = this.el.dataset.title;
    const message = this.el.dataset.message;
    const confirmEvent = this.el.dataset.confirmEvent;
    
    // Listen for the parent button click
    const button = document.querySelector(`[data-action-id="${dialogId}"] button`);
    if (button) {
      button.addEventListener('click', (e) => {
        if (e.target.closest('[phx-click="confirm_action"]')) {
          e.preventDefault();
          e.stopPropagation();
          this.showDialog();
        }
      });
    }
    
    // Handle window events for opening/closing dialogs
    window.addEventListener(`phx:open_confirm_dialog_${dialogId}`, () => {
      this.showDialog();
    });
    
    window.addEventListener(`phx:close_confirm_dialog_${dialogId}`, () => {
      this.hideDialog();
    });
  },
  
  showDialog() {
    // Create and show modal using DaisyUI modal pattern
    const modal = document.createElement('div');
    modal.className = 'modal modal-open';
    modal.innerHTML = `
      <div class="modal-box">
        <h3 class="font-bold text-lg">${this.el.dataset.title}</h3>
        <p class="py-4">${this.el.dataset.message}</p>
        <div class="modal-action">
          <button class="btn btn-ghost" data-action="cancel">Cancel</button>
          <button class="btn btn-primary" data-action="confirm">Confirm</button>
        </div>
      </div>
      <div class="modal-backdrop"></div>
    `;
    
    document.body.appendChild(modal);
    
    // Handle button clicks
    modal.querySelector('[data-action="cancel"]').addEventListener('click', () => {
      document.body.removeChild(modal);
    });
    
    modal.querySelector('[data-action="confirm"]').addEventListener('click', () => {
      // Get the original button params
      const button = document.querySelector(`[data-action-id="${this.el.dataset.actionId}"] button`);
      const params = {};
      
      // Extract phx-value attributes
      Array.from(button.attributes).forEach(attr => {
        if (attr.name.startsWith('phx-value-')) {
          const key = attr.name.replace('phx-value-', '').replace(/-/g, '_');
          params[key] = attr.value;
        }
      });
      
      // Push the confirm event
      this.pushEvent(this.el.dataset.confirmEvent, params);
      document.body.removeChild(modal);
    });
    
    // Close on backdrop click
    modal.querySelector('.modal-backdrop').addEventListener('click', () => {
      document.body.removeChild(modal);
    });
    
    // Close on ESC key
    const handleEsc = (e) => {
      if (e.key === 'Escape') {
        document.body.removeChild(modal);
        document.removeEventListener('keydown', handleEsc);
      }
    };
    document.addEventListener('keydown', handleEsc);
  },
  
  hideDialog() {
    const modal = document.querySelector('.modal.modal-open');
    if (modal) {
      document.body.removeChild(modal);
    }
  }
};

// Confirm Dialog Modal Hook (for standalone dialog widget)
export const ConfirmDialogModal = {
  mounted() {
    // Handle window events for opening/closing
    const dialogId = this.el.dataset.dialogId;
    
    window.addEventListener('phx:open_confirm_dialog', (e) => {
      if (e.detail.id === dialogId) {
        const checkbox = document.querySelector(`#${dialogId}-modal`);
        if (checkbox) checkbox.checked = true;
      }
    });
    
    window.addEventListener('phx:close_confirm_dialog', (e) => {
      if (e.detail.id === dialogId) {
        const checkbox = document.querySelector(`#${dialogId}-modal`);
        if (checkbox) checkbox.checked = false;
      }
    });
  }
};

// Context Menu Hook
export const ContextMenu = {
  mounted() {
    const targetId = this.el.dataset.targetId;
    const position = this.el.dataset.position || 'cursor';
    const targetElement = document.getElementById(targetId);
    
    if (!targetElement) {
      console.error(`Target element #${targetId} not found for context menu`);
      return;
    }
    
    // Prevent default context menu on target
    targetElement.addEventListener('contextmenu', (e) => {
      e.preventDefault();
      this.showMenu(e, position);
    });
    
    // Hide menu when clicking elsewhere
    document.addEventListener('click', (e) => {
      if (!this.el.contains(e.target)) {
        this.hideMenu();
      }
    });
    
    // Hide menu on escape key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.hideMenu();
      }
    });
  },
  
  showMenu(event, position) {
    // Remove hidden class
    this.el.classList.remove('hidden');
    
    // Position the menu
    switch (position) {
      case 'cursor':
        this.el.style.left = `${event.clientX}px`;
        this.el.style.top = `${event.clientY}px`;
        break;
      case 'center':
        const rect = event.target.getBoundingClientRect();
        this.el.style.left = `${rect.left + rect.width / 2 - this.el.offsetWidth / 2}px`;
        this.el.style.top = `${rect.top + rect.height / 2 - this.el.offsetHeight / 2}px`;
        break;
      // Add other positioning options as needed
    }
    
    // Ensure menu stays within viewport
    const menuRect = this.el.getBoundingClientRect();
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;
    
    if (menuRect.right > viewportWidth) {
      this.el.style.left = `${viewportWidth - menuRect.width - 10}px`;
    }
    
    if (menuRect.bottom > viewportHeight) {
      this.el.style.top = `${viewportHeight - menuRect.height - 10}px`;
    }
  },
  
  hideMenu() {
    this.el.classList.add('hidden');
  },
  
  destroyed() {
    // Cleanup event listeners
    const targetId = this.el.dataset.targetId;
    const targetElement = document.getElementById(targetId);
    if (targetElement) {
      targetElement.removeEventListener('contextmenu', this.showMenu);
    }
  }
};

// Export all hooks
export default {
  Sortable,
  ConfirmDialog,
  ConfirmDialogModal,
  ContextMenu
};