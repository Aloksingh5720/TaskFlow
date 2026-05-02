<%@ include file="../layout/header.jsp" %>

    <div class="error-center">
        <div class="error-code">404</div>
        <div class="card-icon card-icon-lg card-icon-primary mx-auto mb-3">
            <i class="bi bi-search"></i>
        </div>
        <h2>Page Not Found</h2>
        <p class="text-muted" style="max-width:400px;text-align:center;margin:0 auto 24px">
            The page you are looking for does not exist, may have been moved, or might be temporarily unavailable.
        </p>
        <div class="d-flex gap-2 justify-content-center">
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">
                <i class="bi bi-house me-2"></i>Go to Dashboard
            </a>
            <button onclick="history.back()" class="btn btn-outline-primary">
                <i class="bi bi-arrow-left me-2"></i>Go Back
            </button>
        </div>
    </div>

    <%@ include file="../layout/footer.jsp" %>