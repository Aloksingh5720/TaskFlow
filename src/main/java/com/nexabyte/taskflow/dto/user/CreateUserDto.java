package com.nexabyte.taskflow.dto.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateUserDto {

    private Long id;

    @NotBlank(message = "Username must not be blank")
    @Size(min = 3, max = 50, message = "Username must be at least 3 characters long")
    private String username;

    @NotBlank(message = "Email must not be blank")
    @Size(max = 100, message = "Email must not exceed 100 characters")
    @Email(message = "Please provide a valid email address")
    private String email;

    @NotBlank(message = "Password must not be blank")
    @Size(min = 6, max = 100, message = "Password must be at least 6 characters long")
    private String password;

    @NotBlank(message = "Name must not be blank")
    @Size(min = 3, message = "Person name must be al teast 3 characters long")
    @Pattern(regexp = "^[\\p{L}]{2,}(?:[ '-][\\p{L}]{2,})*$", message = "Invalid person name")
    private String name;

    private boolean isEnabled;

    @NotNull(message = "Global role is required")
    private Long globalRoleId;

    private String globalRole;
}
