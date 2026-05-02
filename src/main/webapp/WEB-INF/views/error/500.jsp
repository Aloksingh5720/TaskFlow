<%@ include file="../layout/header.jsp" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <div class="error-center">
            <div class="error-code">500</div>
            <div class="card-icon card-icon-lg card-icon-error mx-auto mb-3">
                <i class="bi bi-exclamation-triangle"></i>
            </div>
            <h2>Internal Server Error</h2>
            <p class="text-muted" style="max-width:400px;text-align:center;margin:0 auto 16px">
                Something went wrong on our end. Please try again later, or contact support if the problem persists.
            </p>
            <c:if test="${not empty error}">
                <div class="alert alert-danger" style="max-width:480px;margin:0 auto 20px">
                    <i class="bi bi-bug"></i>
                    <code>${error}</code>
                </div>
            </c:if>
            <div class="d-flex gap-2 justify-content-center">
                <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">
                    <i class="bi bi-house me-2"></i>Go to Dashboard
                </a>
                <button onclick="location.reload()" class="btn btn-outline-primary">
                    <i class="bi bi-arrow-clockwise me-2"></i>Retry
                </button>
            </div>
        </div>

        <%@ include file="../layout/footer.jsp" %>