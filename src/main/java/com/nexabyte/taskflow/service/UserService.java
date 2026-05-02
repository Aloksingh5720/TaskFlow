package com.nexabyte.taskflow.service;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import com.nexabyte.taskflow.dto.csv.CsvUserCreationResultDto;
import com.nexabyte.taskflow.dto.user.CreateUserDto;
import com.nexabyte.taskflow.dto.user.UpdateUserDto;

public interface UserService {

    void createUser(CreateUserDto userDto);

    CsvUserCreationResultDto createUsersFromCsv(MultipartFile file, Long currentUserId);

    void updateUser(Long id, UpdateUserDto userDto);

    void deleteUser(Long id);

    CreateUserDto getUserById(Long id);

    UpdateUserDto getUpdateUserById(Long id);

    List<CreateUserDto> getAllUsers();

    Page<CreateUserDto> getAllUsersPaginated(Pageable pageable);

    Page<CreateUserDto> searchUsers(String searchTerm, Pageable pageable);
}
