package ee.nutrionista.service;

import ee.nutrionista.controller.auth.dto.LoginRequestDto;
import ee.nutrionista.controller.auth.dto.LoginResponseDto;
import ee.nutrionista.infrastructure.exception.BadCredentialsException;
import ee.nutrionista.persistence.user.User;
import ee.nutrionista.persistence.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.stereotype.Service;

import static ee.nutrionista.infrastructure.error.ErrorResponse.INCORRECT_CREDENTIALS;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;

    public LoginResponseDto login(LoginRequestDto request) {
        User user = userRepository.findUserBy(request.getEmail(), request.getPassword())
                .orElseThrow(() -> new BadCredentialsException(
                        INCORRECT_CREDENTIALS.getMessage(),
                        INCORRECT_CREDENTIALS.getErrorCode()));

        return new LoginResponseDto(user.getId(), user.getRole().getName());
    }

}