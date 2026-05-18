package ee.nutrionista.infrastructure.exception;

import lombok.Getter;

@Getter

public class BadCredentialsException extends RuntimeException {
    private final String message;
    private final Integer errorCode;

    public BadCredentialsException(String message, Integer errorCode) {
        super(message);
        this.message = message;
        this.errorCode = errorCode;
    }
}
