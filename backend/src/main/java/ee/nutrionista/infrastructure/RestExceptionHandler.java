package ee.nutrionista.infrastructure;

import ee.nutrionista.infrastructure.error.ApiError;
import ee.nutrionista.infrastructure.exception.BadCredentialsException;
import lombok.NonNull;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@ControllerAdvice
public class RestExceptionHandler extends ResponseEntityExceptionHandler {

    @ExceptionHandler
    public ResponseEntity<ApiError> handleBadCredentialsException(BadCredentialsException exception) {
        ApiError apiError = new ApiError();
        apiError.setMessage(exception.getMessage());
        apiError.setErrorCode(exception.getErrorCode());
        return new ResponseEntity<>(apiError, HttpStatus.UNAUTHORIZED);
    }

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
            MethodArgumentNotValidException ex,
            @NonNull  org.springframework.http.HttpHeaders headers,
            @NonNull HttpStatusCode status,
            @NonNull WebRequest request) {
        FieldError firstError = ex.getBindingResult().getFieldErrors().get(0);
        ApiError apiError = new ApiError();
        apiError.setMessage(firstError.getField() + ": " + firstError.getDefaultMessage());
        apiError.setErrorCode(400);
        return new ResponseEntity<>(apiError, HttpStatus.BAD_REQUEST);
    }
}