<%@ taglib prefix="c" uri="jakarta.tags.core" %>

    <div class="upload-zone mb-2">
        <form method="post" action="${pageContext.request.contextPath}/work-packages/${workPackage.id}/attachments"
            enctype="multipart/form-data" class="d-flex align-items-center gap-3 flex-wrap justify-content-center">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
            <i class="bi bi-cloud-upload card-icon card-icon-md card-icon-primary"></i>
            <div class="flex-grow-1" style="max-width:320px">
                <label for="file" class="form-label mb-1">
                    Choose a file to attach
                </label>
                <input type="file" class="form-control form-control-sm" id="file" name="file" required>
            </div>
            <button type="submit" class="btn btn-primary btn-sm flex-shrink-0">
                <i class="bi bi-upload me-1"></i>Upload
            </button>
        </form>
    </div>