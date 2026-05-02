<%@ taglib prefix="c" uri="jakarta.tags.core" %>

</main>

<footer class="text-center py-2 border-top bg-light">
  <small class="text-muted">&copy; 2026 TaskFlow - NexaByte. All rights reserved.</small>
</footer>
</div><!-- /.app-content -->
</div><!-- /.app-shell -->

<div class="toast-container app-toast-container position-fixed bottom-0 end-0 p-3">
  <c:if test="${not empty message}">
    <div
      class="toast app-toast app-toast--success border-0"
      role="status"
      aria-live="polite"
      aria-atomic="true"
      data-bs-delay="3200"
    >
      <div class="toast-body">
        <div class="app-toast__icon">
          <i class="bi bi-check2-circle"></i>
        </div>
        <div class="app-toast__content">
          <div class="app-toast__title">Success</div>
          <div class="app-toast__message">${message}</div>
        </div>
        <button type="button" class="btn-close app-toast__close" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    </div>
  </c:if>

  <c:if test="${not empty warning}">
    <div
      class="toast app-toast app-toast--warning border-0"
      role="alert"
      aria-live="assertive"
      aria-atomic="true"
      data-bs-delay="5200"
    >
      <div class="toast-body">
        <div class="app-toast__icon">
          <i class="bi bi-exclamation-circle"></i>
        </div>
        <div class="app-toast__content">
          <div class="app-toast__title">Notice</div>
          <div class="app-toast__message">${warning}</div>
        </div>
        <button type="button" class="btn-close app-toast__close" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    </div>
  </c:if>

  <c:if test="${not empty error}">
    <div
      class="toast app-toast app-toast--error border-0"
      role="alert"
      aria-live="assertive"
      aria-atomic="true"
      data-bs-delay="6500"
    >
      <div class="toast-body">
        <div class="app-toast__icon">
          <i class="bi bi-x-circle"></i>
        </div>
        <div class="app-toast__content">
          <div class="app-toast__title">Error</div>
          <div class="app-toast__message">${error}</div>
        </div>
        <button type="button" class="btn-close app-toast__close" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    </div>
  </c:if>

  <c:if test="${not empty errorDetails}">
    <c:forEach items="${errorDetails}" var="errorDetail">
      <div
        class="toast app-toast app-toast--error border-0"
        role="alert"
        aria-live="assertive"
        aria-atomic="true"
        data-bs-delay="7000"
      >
        <div class="toast-body">
          <div class="app-toast__icon">
            <i class="bi bi-exclamation-octagon"></i>
          </div>
          <div class="app-toast__content">
            <div class="app-toast__title">Import Error</div>
            <div class="app-toast__message">${errorDetail}</div>
          </div>
          <button type="button" class="btn-close app-toast__close" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
      </div>
    </c:forEach>
  </c:if>
</div>

<%@ include file="_delete-confirm-modal.jsp" %>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>

</html>
