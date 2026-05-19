package ee.nutrionista.persistence.blog;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "blog_article", schema = "nutrionista")
public class BlogArticle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Integer id;

    @Size(max = 255)
    @NotNull
    @Column(name = "title", nullable = false)
    private String title;

    @Size(max = 500)
    @Column(name = "summary")
    private String summary;

    @Size(max = 5000)
    @Column(name = "content")
    private String content;

    @Size(max = 1000)
    @Column(name = "image_url")
    private String imageUrl;
}
