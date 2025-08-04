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

// Export all hooks
export default {
  Sortable
};