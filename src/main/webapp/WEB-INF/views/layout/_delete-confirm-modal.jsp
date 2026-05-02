<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="modal fade" id="deleteConfirmModal" tabindex="-1" aria-labelledby="deleteConfirmModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-2">
            <form id="deleteConfirmForm" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="modal-header bg-danger bg-opacity-10">
                    <h5 class="modal-title text-danger" id="deleteConfirmModalLabel">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>Confirm Delete
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p id="deleteConfirmMessage" class="mb-0">Are you sure you want to delete this item? This action cannot be undone.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger">
                        <i class="bi bi-trash me-1"></i>Delete
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    (function () {
        var deleteModal = document.getElementById('deleteConfirmModal');
        if (!deleteModal) return;
        deleteModal.addEventListener('show.bs.modal', function (event) {
            var trigger = event.relatedTarget;
            if (!trigger) return;
            var action = trigger.getAttribute('data-delete-action');
            var message = trigger.getAttribute('data-delete-message');
            var form = deleteModal.querySelector('#deleteConfirmForm');
            var msg = deleteModal.querySelector('#deleteConfirmMessage');
            if (form && action) form.setAttribute('action', action);
            if (msg && message) msg.textContent = message;
        });
    })();
</script>
