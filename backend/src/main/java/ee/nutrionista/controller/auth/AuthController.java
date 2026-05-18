package ee.nutrionista.controller.auth;

import ee.nutrionista.controller.auth.dto.LoginRequestDto;
import ee.nutrionista.controller.auth.dto.LoginResponseDto;
import ee.nutrionista.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "Sisselogimine")
    public  LoginResponseDto login(@Valid @RequestBody LoginRequestDto body) {
        return authService.login(body);
    }
}
