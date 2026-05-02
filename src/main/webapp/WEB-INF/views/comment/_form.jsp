<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="mt-3">
  <div class="section-label mb-2">
    <i class="bi bi-send me-1"></i>Add Comment
  </div>
  <form
    method="post"
    action="${pageContext.request.contextPath}/work-packages/${workPackage.id}/comments"
  >
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
    <div class="mb-3">
      <textarea
        class="form-control"
        id="content"
        name="content"
        rows="3"
        placeholder="Write a comment"
        required
      ></textarea>
    </div>
    <button type="submit" class="btn btn-primary btn-sm">
      <i class="bi bi-send me-1"></i>Post Comment
    </button>
  </form>
</div>
