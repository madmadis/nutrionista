package ee.nutrionista.persistence.user;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {


    @Query("select u from User u where u.email = ?1 and u.passwordHash = ?2")
    Optional<User> findUserBy(String email, String passwordHash);
}