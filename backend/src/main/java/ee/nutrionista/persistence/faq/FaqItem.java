package ee.nutrionista.persistence.faq;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "faq_item", schema = "nutrionista")
public class FaqItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Integer id;

    @Size(max = 255)
    @NotNull
    @Column(name = "section", nullable = false)
    private String section;

    @Size(max = 500)
    @NotNull
    @Column(name = "question", nullable = false)
    private String question;

    @Size(max = 2000)
    @NotNull
    @Column(name = "answer", nullable = false)
    private String answer;
}
