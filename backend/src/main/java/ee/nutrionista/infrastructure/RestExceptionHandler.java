package ee.nutrionista.infrastructure;

import ee.nutrionista.infrastructure.error.ApiError;
import ee.nutrionista.infrastructure.exception.BadCredentialsException;
import ee.nutrionista.infrastructure.exception.CartNotFoundException;
import ee.nutrionista.infrastructure.exception.NutrientNotFoundException;
import jakarta.persistence.EntityNotFoundException;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@Slf4j
@ControllerAdvice
public class RestExceptionHandler extends ResponseEntityExceptionHandler {

    // TODO: 1 abstraktne baasklass, mida kõik exceptionid laiendaksid, et piisaks ühest handlerist
    @ExceptionHandler
    public ResponseEntity<ApiError> handleBadCredentialsException(BadCredentialsException exception) {
        ApiError apiError = new ApiError();
        apiError.setMessage(exception.getMessage());
        apiError.setErrorCode(exception.getErrorCode());
        return new ResponseEntity<>(apiError, HttpStatus.UNAUTHORIZED);
    }

    @ExceptionHandler
    public ResponseEntity<ApiError> handleNutrientNotFoundException(NutrientNotFoundException nutrientNotFoundException) {
        ApiError apiError = new ApiError();
        apiError.setMessage(nutrientNotFoundException.getMessage());
        apiError.setErrorCode(nutrientNotFoundException.getErrorCode());
        return new ResponseEntity<>(apiError, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler
    public ResponseEntity<ApiError> handleCartNotFoundException(CartNotFoundException cartNotFoundException) {
        ApiError apiError = new ApiError();
        apiError.setMessage(cartNotFoundException.getMessage());
        apiError.setErrorCode(cartNotFoundException.getErrorCode());
        return new ResponseEntity<>(apiError, HttpStatus.NOT_FOUND);
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
    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ApiError> handleEntityNotFound(EntityNotFoundException exception) {
        ApiError apiError = new ApiError();

        String message;
        if (exception.getMessage() != null) {
            message = exception.getMessage();
        } else {
            message = "Andmeid ei leitud";
        }
        apiError.setMessage(message);

        apiError.setErrorCode(404);
        return new ResponseEntity<>(apiError, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ApiError> handleRuntime(RuntimeException exception) {
        log.error("Unhandled runtime exception", exception);
        ApiError apiError = new ApiError();
        apiError.setMessage("Sisemine viga");
        apiError.setErrorCode(500);
        return new ResponseEntity<>(apiError, HttpStatus.INTERNAL_SERVER_ERROR);
    }

}