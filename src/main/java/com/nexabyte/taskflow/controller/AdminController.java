package com.nexabyte.taskflow.controller;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;

import java.util.List;

import org.springframework.beans.propertyeditors.StringTrimmerEditor;
import org.springframework.ui.Model;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.nexabyte.taskflow.dto.csv.CsvUserCreationResultDto;
import com.nexabyte.taskflow.dto.user.CreateUserDto;
import com.nexabyte.taskflow.dto.user.UpdateUserDto;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.exception.ResourceAlreadyExistsException;
import com.nexabyte.taskflow.service.RoleService;
import com.nexabyte.taskflow.service.UserService;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final UserService userService;
    private final RoleService roleService;

    @InitBinder
    public void initBinder(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    @GetMapping("/users")
    public String listAndSearchUsers(Model model,
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "id") String sortField,
            @RequestParam(defaultValue = "asc") String sortDir,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Long editUserId) {
        populateUsersPageModel(model, user.getId(), page, sortField, sortDir, search);
        if (editUserId != null && !model.containsAttribute("editUser")) {
            model.addAttribute("editUser", userService.getUpdateUserById(editUserId));
            model.addAttribute("showEditUserModal", true);
        }
        return "admin/users";
    }

    private void populateUsersPageModel(Model model, Long currentUserId, int page, String sortField, String sortDir,
            String search) {

        Sort sort = sortDir.equalsIgnoreCase("asc")
                ? Sort.by(sortField).ascending()
                : Sort.by(sortField).descending();

        Pageable pageable = PageRequest.of(page, 10, sort);
        Page<CreateUserDto> usersPage = userService.searchUsers(search, pageable);

        model.addAttribute("users", usersPage);
        model.addAttribute("currentPage", page);
        model.addAttribute("pageSize", 10);
        model.addAttribute("sortField", sortField);
        model.addAttribute("sortDir", sortDir);
        model.addAttribute("reverseSortDir", sortDir.equals("asc") ? "desc" : "asc");
        model.addAttribute("search", search);

        int totalPages = usersPage.getTotalPages();
        int startPage = Math.max(0, page - 2);
        int endPage = Math.min(totalPages - 1, page + 2);

        model.addAttribute("startPage", startPage);
        model.addAttribute("endPage", endPage);
        model.addAttribute("totalPages", totalPages);
        if (!model.containsAttribute("createUser")) {
            model.addAttribute("createUser", new CreateUserDto());
        }
        model.addAttribute("roles", roleService.getAssignableGlobalRoles(currentUserId));
        if (!model.containsAttribute("showCreateUserModal")) {
            model.addAttribute("showCreateUserModal", false);
        }
        if (!model.containsAttribute("editUser")) {
            model.addAttribute("editUser", new UpdateUserDto());
        }
        if (!model.containsAttribute("showEditUserModal")) {
            model.addAttribute("showEditUserModal", false);
        }
    }

    @GetMapping("/users/new")
    public String newUserForm(Model model, @AuthenticationPrincipal User user) {
        model.addAttribute("createUser", new CreateUserDto());
        model.addAttribute("roles", roleService.getAssignableGlobalRoles(user.getId()));
        return "redirect:/admin/users";
    }

    @PostMapping("/users")
    public String createUser(@Validated @ModelAttribute("createUser") CreateUserDto userDto,
            BindingResult result,
            RedirectAttributes redirectAttributes,
            Model model,
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "id") String sortField,
            @RequestParam(defaultValue = "asc") String sortDir,
            @RequestParam(required = false) String search) {

        if (result.hasErrors()) {
            model.addAttribute("showCreateUserModal", true);
            populateUsersPageModel(model, user.getId(), page, sortField, sortDir, search);
            return "admin/users";
        }

        try {
            userService.createUser(userDto);
        } catch (ResourceAlreadyExistsException | IllegalArgumentException exception) {
            result.reject("error.user", exception.getMessage());
            model.addAttribute("showCreateUserModal", true);
            populateUsersPageModel(model, user.getId(), page, sortField, sortDir, search);
            return "admin/users";
        }

        redirectAttributes.addFlashAttribute("message", "User created successfully");
        redirectAttributes.addAttribute("page", page);
        redirectAttributes.addAttribute("sortField", sortField);
        redirectAttributes.addAttribute("sortDir", sortDir);
        if (search != null && !search.isBlank()) {
            redirectAttributes.addAttribute("search", search);
        }
        return "redirect:/admin/users";
    }

    @GetMapping("/users/{id}/edit")
    public String editUserForm(@PathVariable Long id,
            RedirectAttributes redirectAttributes,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "id") String sortField,
            @RequestParam(defaultValue = "asc") String sortDir,
            @RequestParam(required = false) String search) {
        redirectAttributes.addAttribute("editUserId", id);
        redirectAttributes.addAttribute("page", page);
        redirectAttributes.addAttribute("sortField", sortField);
        redirectAttributes.addAttribute("sortDir", sortDir);
        if (search != null && !search.isBlank()) {
            redirectAttributes.addAttribute("search", search);
        }
        return "redirect:/admin/users";
    }

    @PostMapping("/users/{id}")
    public String updateUser(@PathVariable Long id,
            @Validated @ModelAttribute("editUser") UpdateUserDto userDto,
            BindingResult result,
            RedirectAttributes redirectAttributes,
            Model model,
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "id") String sortField,
            @RequestParam(defaultValue = "asc") String sortDir,
            @RequestParam(required = false) String search) {
        if (result.hasErrors()) {
            userDto.setId(id);
            model.addAttribute("showEditUserModal", true);
            populateUsersPageModel(model, user.getId(), page, sortField, sortDir, search);
            return "admin/users";
        }
        try {
            userService.updateUser(id, userDto);
        } catch (IllegalArgumentException | ResourceAlreadyExistsException exception) {
            result.reject("error.user", exception.getMessage());
            userDto.setId(id);
            model.addAttribute("showEditUserModal", true);
            populateUsersPageModel(model, user.getId(), page, sortField, sortDir, search);
            return "admin/users";
        }
        redirectAttributes.addFlashAttribute("message", "User updated successfully");
        redirectAttributes.addAttribute("page", page);
        redirectAttributes.addAttribute("sortField", sortField);
        redirectAttributes.addAttribute("sortDir", sortDir);
        if (search != null && !search.isBlank()) {
            redirectAttributes.addAttribute("search", search);
        }
        return "redirect:/admin/users";
    }

    @PostMapping("/users/{id}/delete")
    public String deleteUser(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        userService.deleteUser(id);
        redirectAttributes.addFlashAttribute("message", "User deleted");
        return "redirect:/admin/users";
    }

    @PostMapping("/users/import")
    public String importUsersFromCsv(
            @RequestParam("file") MultipartFile file,
            RedirectAttributes redirectAttributes,
            @AuthenticationPrincipal User currentUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "id") String sortField,
            @RequestParam(defaultValue = "asc") String sortDir,
            @RequestParam(required = false) String search,
            HttpServletRequest request) { // Add HttpServletRequest for CSRF debugging

        if (file.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Please select a file to upload");
            return "redirect:/admin/users";
        }

        // Check file size
        if (file.getSize() > 10 * 1024 * 1024) { // 10MB
            redirectAttributes.addFlashAttribute("error", "File size exceeds 10MB limit");
            return "redirect:/admin/users";
        }

        // Validate file type
        String contentType = file.getContentType();
        if (contentType == null
                || (!contentType.equals("text/csv") && !contentType.equals("application/vnd.ms-excel"))) {
            redirectAttributes.addFlashAttribute("error", "Only CSV files are allowed");
            return "redirect:/admin/users";
        }

        try {
            CsvUserCreationResultDto result = userService.createUsersFromCsv(file, currentUser.getId());

            if (result.getSuccessCount() > 0) {
                redirectAttributes.addFlashAttribute("message",
                        String.format("Successfully created %d user(s) out of %d",
                                result.getSuccessCount(), result.getTotalRecords()));
            }

            if (result.getFailureCount() > 0) {
                redirectAttributes.addFlashAttribute("warning",
                        String.format("%d user(s) failed to create.", result.getFailureCount()));
                // Limit error messages to avoid oversized redirect attributes
                List<String> limitedErrors = result.getErrorMessages().size() > 5
                        ? result.getErrorMessages().subList(0, 5)
                        : result.getErrorMessages();
                redirectAttributes.addFlashAttribute("errorDetails", limitedErrors);
            }

        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", "Invalid CSV format: " + e.getMessage());
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed to process CSV: " + e.getMessage());
            e.printStackTrace(); // Log the error
        }

        redirectAttributes.addAttribute("page", page);
        redirectAttributes.addAttribute("sortField", sortField);
        redirectAttributes.addAttribute("sortDir", sortDir);
        if (search != null && !search.isBlank()) {
            redirectAttributes.addAttribute("search", search);
        }

        return "redirect:/admin/users";
    }
}
