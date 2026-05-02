package com.nexabyte.taskflow.service.impl;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.acls.model.NotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.nexabyte.taskflow.constants.GlobalRole;
import com.nexabyte.taskflow.dto.csv.CsvUserCreationResultDto;
import com.nexabyte.taskflow.dto.user.CreateUserDto;
import com.nexabyte.taskflow.dto.user.UpdateUserDto;
import com.nexabyte.taskflow.entities.Role;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.exception.ResourceAlreadyExistsException;
import com.nexabyte.taskflow.exception.ResourceNotFoundException;
import com.nexabyte.taskflow.mapper.UserMapper;
import com.nexabyte.taskflow.repository.RoleRepository;
import com.nexabyte.taskflow.repository.UserRepository;
import com.nexabyte.taskflow.service.UserService;
import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvException;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void createUser(CreateUserDto userDto) {
        if (userRepository.existsByUsername(userDto.getUsername())) {
            throw new ResourceAlreadyExistsException("User", "username", userDto.getUsername());
        }

        if (userRepository.existsByEmail(userDto.getEmail())) {
            throw new ResourceAlreadyExistsException("Email", "email", userDto.getEmail());
        }

        Role globalRole = roleRepository.findById(userDto.getGlobalRoleId())
                .orElseThrow(
                        () -> new ResourceNotFoundException("Role", "roleId", userDto.getGlobalRoleId().toString()));

        if (GlobalRole.SUPER_ADMIN.equals(globalRole.getName())) {
            throw new IllegalArgumentException("Creating user with SUPER_ADMIN role is restricted");
        }

        User user = User.builder()
                .username(userDto.getUsername())
                .email(userDto.getEmail())
                .password(passwordEncoder.encode(userDto.getPassword()))
                .name(userDto.getName())
                .enabled(userDto.isEnabled())
                .globalRole(globalRole)
                .build();

        userRepository.save(user);
    }

    @Override
    @Transactional
    public CsvUserCreationResultDto createUsersFromCsv(MultipartFile file, Long currentUserId) {
        List<String> successMessages = new ArrayList<>();
        List<String> errorMessages = new ArrayList<>();
        int successCount = 0;
        List<String[]> records = null;

        try (InputStream inputStream = file.getInputStream();
                InputStreamReader reader = new InputStreamReader(inputStream, StandardCharsets.UTF_8);
                CSVReader csvReader = new CSVReader(reader)) {

            records = csvReader.readAll();

            if (records.isEmpty()) {
                throw new IllegalArgumentException("CSV file is empty");
            }

            String[] header = records.get(0);

            // Validate header has all required columns
            if (header.length < 6) {
                throw new IllegalArgumentException(
                        "Invalid CSV format. Expected 6 columns: username,email,password,name,enabled,globalRoleId");
            }

            // Validate column names
            List<String> expectedColumns = Arrays.asList("username", "email", "password", "name", "enabled",
                    "globalRoleId");
            for (int i = 0; i < expectedColumns.size(); i++) {
                if (!header[i].trim().equalsIgnoreCase(expectedColumns.get(i))) {
                    throw new IllegalArgumentException(
                            String.format("Invalid CSV header. Expected '%s' at column %d, but found '%s'",
                                    expectedColumns.get(i), i + 1, header[i].trim()));
                }
            }

            for (int i = 1; i < records.size(); i++) {
                String[] record = records.get(i);

                // Skip empty rows
                if (record == null || record.length < 6) {
                    errorMessages
                            .add(String.format("✗ Row %d: Invalid format - missing columns (need 6 columns)", i + 1));
                    continue;
                }

                // Trim all values and handle empty strings
                String[] trimmedRecord = Arrays.stream(record)
                        .map(s -> s != null ? s.trim() : "")
                        .toArray(String[]::new);

                if (Arrays.stream(trimmedRecord).allMatch(String::isEmpty)) {
                    continue; // Skip completely empty rows
                }

                try {
                    CreateUserDto userDto = new CreateUserDto();

                    // Validate required fields
                    if (trimmedRecord[0].isEmpty()) {
                        throw new IllegalArgumentException("Username is required");
                    }
                    if (trimmedRecord[1].isEmpty()) {
                        throw new IllegalArgumentException("Email is required");
                    }
                    if (trimmedRecord[2].isEmpty()) {
                        throw new IllegalArgumentException("Password is required");
                    }
                    if (trimmedRecord[3].isEmpty()) {
                        throw new IllegalArgumentException("Name is required");
                    }
                    if (trimmedRecord[4].isEmpty()) {
                        throw new IllegalArgumentException("Enabled flag is required (true/false)");
                    }
                    if (trimmedRecord[5].isEmpty()) {
                        throw new IllegalArgumentException("Global Role ID is required (2 for ADMIN, 3 for USER)");
                    }

                    userDto.setUsername(trimmedRecord[0]);
                    userDto.setEmail(trimmedRecord[1]);
                    userDto.setPassword(trimmedRecord[2]);
                    userDto.setName(trimmedRecord[3]);

                    // Handle enabled flag
                    if (!trimmedRecord[4].equalsIgnoreCase("true") && !trimmedRecord[4].equalsIgnoreCase("false")) {
                        throw new IllegalArgumentException(
                                "Enabled must be 'true' or 'false', got: " + trimmedRecord[4]);
                    }
                    userDto.setEnabled(Boolean.parseBoolean(trimmedRecord[4]));

                    // Validate and set role ID
                    Long roleId;
                    try {
                        roleId = Long.parseLong(trimmedRecord[5]);
                    } catch (NumberFormatException e) {
                        throw new IllegalArgumentException("Invalid role ID format: " + trimmedRecord[5]
                                + ". Must be a number (2 for ADMIN, 3 for USER)");
                    }

                    // Validate role ID is either 2 (ADMIN) or 3 (USER)
                    if (roleId != 2L && roleId != 3L) {
                        throw new IllegalArgumentException(
                                "Invalid role ID: " + roleId + ". Must be 2 (ADMIN) or 3 (USER)");
                    }

                    userDto.setGlobalRoleId(roleId);

                    // Create the user
                    createUser(userDto);
                    successMessages.add(String.format("✓ User '%s' created successfully with %s role",
                            userDto.getUsername(), roleId == 2L ? "ADMIN" : "USER"));
                    successCount++;

                } catch (Exception e) {
                    String username = trimmedRecord.length > 0 && !trimmedRecord[0].isEmpty()
                            ? trimmedRecord[0]
                            : "Row " + (i + 1);
                    errorMessages.add(String.format("✗ Failed to create user '%s': %s", username, e.getMessage()));
                }
            }

        } catch (CsvException exception) {
            throw new IllegalArgumentException("Invalid CSV format: " + exception.getMessage());
        } catch (IOException exception) {
            throw new RuntimeException("Failed to read CSV file", exception);
        }

        int totalRecords = records != null ? records.size() - 1 : 0;

        return CsvUserCreationResultDto.builder()
                .totalRecords(totalRecords)
                .successCount(successCount)
                .failureCount(errorMessages.size())
                .successMessages(successMessages)
                .errorMessages(errorMessages)
                .build();
    }

    @Override
    public void updateUser(Long id, UpdateUserDto updateUserDto) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("User not found with id: " + id));

        if (!user.getEmail().equals(updateUserDto.getEmail())
                && userRepository.existsByEmail(updateUserDto.getEmail())) {
            throw new IllegalArgumentException("Email '" + updateUserDto.getEmail() + "' already exists");
        }

        // Check username uniqueness if changed
        if (!user.getUsername().equals(updateUserDto.getUsername())
                && userRepository.existsByUsername(updateUserDto.getUsername())) {
            throw new IllegalArgumentException("Username '" + updateUserDto.getUsername() + "' already exists");
        }

        user.setUsername(updateUserDto.getUsername());
        user.setEmail(updateUserDto.getEmail());
        user.setName(updateUserDto.getName());
        user.setEnabled(updateUserDto.isEnabled());
        if (updateUserDto.getPassword() != null && !updateUserDto.getPassword().isBlank()) {
            user.setPassword(passwordEncoder.encode(updateUserDto.getPassword()));
        }

        Role globalRole = roleRepository.findById(updateUserDto.getGlobalRoleId())
                .orElseThrow(
                        () -> new ResourceNotFoundException("Role", "roleId",
                                updateUserDto.getGlobalRoleId().toString()));

        if (GlobalRole.SUPER_ADMIN.equals(globalRole.getName())) {
            throw new IllegalArgumentException("Creating user with SUPER_ADMIN role is restricted");
        }

        user.setGlobalRole(globalRole);
        userRepository.save(user);
    }

    @Override
    public void deleteUser(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("User not found with id: " + id));
        userRepository.delete(user);
    }

    @Override
    public CreateUserDto getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("User not found with id: " + id));
        return UserMapper.toDto(user);
    }

    @Override
    public UpdateUserDto getUpdateUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("User not found with id: " + id));
        return UserMapper.toUpdateDto(user);
    }

    @Override
    public List<CreateUserDto> getAllUsers() {
        return userRepository.findAll().stream().map(UserMapper::toDto).toList();
    }

    @Override
    public Page<CreateUserDto> getAllUsersPaginated(Pageable pageable) {
        Page<User> userPage = userRepository.findByGlobalRole_NameNot(GlobalRole.SUPER_ADMIN, pageable);
        return userPage.map(UserMapper::toDto);
    }

    @Override
    public Page<CreateUserDto> searchUsers(String searchTerm, Pageable pageable) {

        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            return userRepository.findByGlobalRole_NameNot(GlobalRole.SUPER_ADMIN, pageable)
                    .map(UserMapper::toDto);
        }

        String cleanSearchTerm = searchTerm.trim();
        Page<User> userPage = userRepository.searchUsersExcludingRole(
                cleanSearchTerm, GlobalRole.SUPER_ADMIN, pageable);

        return userPage.map(UserMapper::toDto);
    }
}
