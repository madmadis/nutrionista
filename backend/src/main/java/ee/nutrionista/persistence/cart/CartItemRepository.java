package ee.nutrionista.persistence.cart;

import org.springframework.data.jpa.repository.JpaRepository;


public interface CartItemRepository extends JpaRepository<CartItem, Integer> {
}
